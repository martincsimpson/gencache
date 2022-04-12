require 'sidekiq'

module GenCache
    class Cache
        class BackgroundFetcher
            include Sidekiq::Worker
    
            def perform(cache_name, item_id)
                GenCache.with_cache(cache_name).background_fetch(item_id)
            end
        end
    end
end