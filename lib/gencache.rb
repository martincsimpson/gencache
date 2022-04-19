module GenCache

    # Find a cache that has been specified
    # This is then used to operate specific queries
    def self.with_cache(cache_name, namespace: )
        GenCache.log :debug, "with_cache", "using #{cache_name} with namespace #{namespace}"
        config = GenCache.configuration.cache_configs.find { |c| c.name == cache_name }
        raise GenCache::Error::CacheConfigNotFound unless config
        
        Cache.new(config: config, namespace: namespace)
    end

    def self.log level, context, message
        case level
        when :debug
            configuration.logger.debug "[#{context}] #{message}" if configuration.debug_mode
        when :info
            configuration.logger.info "[#{context}] #{message}"
        when :warn
            configuration.logger.warn "[#{context}] #{message}"
        when :error
            configuration.logger.error "[#{context}] #{message}"
        end
    end

end