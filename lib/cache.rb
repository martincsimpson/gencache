module GenCache
    class Cache
        def initialize(config:)
            @config = config
            @mode = Mode.new(config: config)
            @storage = Storage.new(config: config)
        end

        def get item_id
            # Fetch from the cache storage, with the stale flag set
            # Also determine if stale is allowed or not
            wrapped_item = @storage.get(item_id)
            item = wrapped_item.unwrap
            metadata = wrapped_item.metadata

            stale = @config.control_class.stale?(item, metadata)
            stale_allowed = @config.control_class.stale_allowed?(item, metadata)

            # If we don't have the item in our cache, then try and do a direct fetch
            # Or, if the item is stale and we don't allow stale then direct fetch
            if !wrapped_item || (stale && !stale_allowed)
                raise GenCache::Error::CacheIsOffline unless @mode.can_fetch_inline?
                return direct_fetch(item_id)
            end

            # If we have a stale item, and we allow stale, trigger a background refresh
            # Or, if we hit a smart refresh, trigger a background refresh
            if @config.control_class.smart_refresh?(item, metadata) || (stale && stale_allowed)
                background_refresh(item_id)
            end

            wrapped_item.unwrap
        end

        def set item
            raise GenCache::Error::ItemClassIncorrect unless item.class == @config.item_class
            @storage.set(item)
        end

        def delete item_id
            @storage.delete(item_id)
        end

        # This is only used by the background refresher job.
        def background_fetch item_id
            raise GenCache::Error::CacheIsOffline unless @mode.can_fetch_background?
            direct_fetch(item_id)
        end

        private
        def background_refresh(item_id)
            BackgroundFetcher.perform_async(item_id)
        end

        def direct_fetch(item_id)
            item = @config.control_class.fetch(item_id)
            set(item)
            item
        rescue GenCache::Error::ItemNotFound => e
            delete(item_id)
            raise e
        end
    end
end