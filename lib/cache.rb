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

        def get item_id
            # Fetch from the cache storage, with the stale flag set
            # Also determine if stale is allowed or not
            wrapped_item = @storage.get(item_id)
            item = wrapped_item.unwrap
            metadata = wrapped_item.metadata
            @logger.log :debug, "cache_get", "item_id: #{item_id}, item: #{item}, metadata: #{metadata}"

            stale = @config.control_class.stale?(item, metadata)
            stale_allowed = @config.control_class.stale_allowed?(item, metadata)
            @logger.log :debug, "cache_get", "stale: #{stale}, stale_allowed: #{stale_allowed}"

            # If we don't have the item in our cache, then try and do a direct fetch
            # Or, if the item is stale and we don't allow stale then direct fetch
            if !wrapped_item || (stale && !stale_allowed)
                @logger.log :debug, "cache_get", "no item, or stale and stale is not allowed"
                raise GenCache::Error::CacheIsOffline unless @mode.can_fetch_inline?
                return direct_fetch(item_id)
            end

            # If we have a stale item, and we allow stale, trigger a background refresh
            # Or, if we hit a smart refresh, trigger a background refresh
            if @config.control_class.smart_refresh?(item, metadata) || (stale && stale_allowed)
                @logger.log :debug, "cache_get", "smart refresh, or stale and stale allowed, trigger background refresh"
                background_refresh(item_id)
            end

            @logger.log :debug, "cache_get", "returning unwrapped item"
            item
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
            raise GenCache::Error::CacheIsOffline unless @mode.can_fetch_background?
            direct_fetch(item_id)
        end

        private
        def background_refresh(item_id)
            @logger.log :debug, "cache_background_fetch", "triggering background fetch to sidekiq"
            #BackgroundFetcher.perform_async(item_id)
        end

        def direct_fetch(item_id)
            @logger.log :debug, "cache_direct_fetch", "fetching #{item_id} from control class #{@config.control_class}"
            item = @config.control_class.fetch(item_id)
            set(item_id, item)
            item
        rescue GenCache::Error::ItemNotFound => e
            delete(item_id)
            raise e
        end
    end
end