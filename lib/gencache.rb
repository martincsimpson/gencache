module GenCache

    # Find a cache that has been specified
    # This is then used to operate specific queries
    def self.with_cache(cache_name)
        config = GenCache.configuration.cache_configs.find { |c| c.name == cache_name }
        raise GenCache::Error::CacheConfigNotFound unless config
        
        Cache.new(config: config)
    end

end