module GenCache
    class Cache
        def initialize(config:, namespace:, mode: Mode, storage: Storage, logger: GenCache)
            @namespace = namespace
            @config = config
            @logger = logger
            @mode = mode.new(config: config)
            @storage = storage.new(config: config, namespace: @namespace)
            @logger.log :debug, "cache_initialize", "config: #{@config}, mode: #{@mode}, storage: #{@storage}, namespace: #{@namespace}"
        end

        def get item_ids
            item_result_set = {}

            wrapped_items = @storage.get(item_ids)

            missing_item_ids = item_ids - wrapped_items.map { |w| w.id }

            missing_item_ids.each do |item_id|
                item_result_set[item_id] = Cache::Result.missing!(item_id)
            end

            wrapped_items.each do |wrapped_item|
                # Get a list of items marked stale
                item = wrapped_item.unwrap
                metadata = wrapped_item.metadata
                @logger.log :debug, "cache_get", "item_id: #{wrapped_item.id}, item: #{item}, metadata: #{metadata}"
    
                stale = @config.control_class.stale?(item, metadata)
                stale_allowed = @config.control_class.stale_allowed?(item, metadata)
                @logger.log :debug, "cache_get", "stale: #{stale}, stale_allowed: #{stale_allowed}"
    
                # If we don't have the item in our cache, then report result as missing
                if !item
                    @logger.log :debug, "cache_get", "no item"
                    result = Cache::Result.missing!(wrapped_item.id)
                    background_refresh(wrapped_item.id)
                end

                # If the item is stale and stale is not allowed
                if stale && !stale_allowed
                    @logger.log :debug, "cache_get", "stale and stale is not allowed"
                    result = Cache::Result.stale_not_ok!(wrapped_item.id, item)
                    background_refresh(wrapped_item.id)
                end
    
                # If we have a stale item, and we allow stale, trigger a background refresh
                if (stale && stale_allowed)
                    @logger.log :debug, "cache_get", "stale and stale allowed, trigger background refresh"
                    result = Cache::Result.stale_ok!(wrapped_item.id, item)
                    background_refresh(wrapped_item.id)
                end

                # If we hit a smart refresh, trigger a background refresh
                if @config.control_class.smart_refresh?(item, metadata)
                    @logger.log :debug, "cache_get", "smart refresh, trigger background refresh"
                    background_refresh(wrapped_item.id)
                end

                result = Cache::Result.ok!(wrapped_item.id, item) unless result

                @logger.log :debug, "cache_get", "returning #{result}"
                item_result_set[wrapped_item.id] = result
            end

            error_ids = item_result_set.map { |k,v| v.status == :error ? v.id : nil }.compact
            @logger.log :debug, "cache_get", "checking for errored ids: #{error_ids}"

            result_set_to_cache = []

            begin
                unless error_ids.empty?
                    if block_given?
                        raise GenCache::Error::CacheIsOffline unless @mode.can_fetch_inline?
                        items = yield error_ids
                        raise GenCache::Error::FetchItemsUnexpectedFormat unless items.is_a?(Hash)
                    else
                        items = direct_fetch(error_ids, :inline)
                    end
                    
                    items.each do |id, item|
                        if item
                            @logger.log :debug, "cache_get", "direct_fetch success for error ID: #{id}"
                            item_result_set[id] = Cache::Result.ok!(id, item)
                            result_set_to_cache[id] << item
                        else
                            @logger.log :debug, "cache_get", "direct_fetch fail for error ID: #{id}"
                            item_result_set[id] = Cache::Result.missing!(id)
                        end
                    end
                end
            rescue StandardError => e
                error_ids.each do |error_id|
                    @logger.log :debug, "cache_get", "direct_fetch error for error ID: #{id}"
                    item_result_set[error_id] = Cache::Result.error!(error_id, e)
                end
            end
            
            # TODO: Change this to be multple set instead of one by one
            result_set_to_cache.each do |id, item|
                set(id, item)
            end

            item_result_set.merge({result_set_to_cache})
        end

        def set id, item
            @logger.log :debug, "cache_set", "id: #{id}, item: #{item} item_class: #{item.class} config_item_class: #{@config.item_class}"
            raise GenCache::Error::ItemClassIncorrect unless item.is_a?(@config.item_class)
            @storage.set(id, item)
        end

        def delete item_id
            @logger.log :debug, "cache_delete", "item_id: #{item_id}"
            @storage.delete(item_id)
        end

        # This is only used by the background refresher job.
        def background_fetch item_id
            @logger.log :debug, "cache_background_fetch", "triggering background fetch for #{item_id}"
            direct_fetch(item_id, :background)
        end

        private
        def background_refresh(item_id)
            @logger.log :debug, "cache_background_fetch", "triggering background fetch to sidekiq"
            #BackgroundFetcher.perform_async(item_id)
        end

        def direct_fetch(item_ids, type)
            if type == :inline
                raise GenCache::Error::CacheIsOffline unless @mode.can_fetch_inline?
            elsif type == :background
                raise GenCache::Error::CacheIsOffline unless @mode.can_fetch_background?
            else
                raise "UnknownFetchType"
            end

            @logger.log :debug, "cache_direct_fetch", "fetching #{item_ids} from control class #{@config.control_class}"
            items = @config.control_class.fetch(item_ids)
            items.each { |item_id,item| set(item_id, item) if item }
            items
        rescue GenCache::Error::ItemNotFound => e
            delete(item_id)
            raise e
        end
    end
end