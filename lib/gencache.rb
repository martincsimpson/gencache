require "gencache/cache/background_fetcher"
require "gencache/cache/configuration"
require "gencache/cache/mode"
require "gencache/cache/result"
require "gencache/cache/configuration"
require "gencache/storage/drivers/cassandra"
require "gencache/storage/drivers/memory"
require "gencache/storage/storage"
require "gencache/storage/wrapper"
require "gencache/configuration"
require "gencache/cache"
require "gencache/error"

module GenCache

    # Find a cache that has been specified
    # This is then used to operate specific queries
    def self.with_cache(cache_name, namespace:, logger: GenCache, configs: GenCache.configuration.cache_configs)
        logger.log :debug, "with_cache", "using #{cache_name} with namespace #{namespace}"
        config = configs.find { |c| c.name == cache_name }
        raise GenCache::Error::CacheConfigNotFound unless config
        
        Cache.new(config: config, namespace: namespace)
    end

    def self.log level, context, message, logger: configuration.logger, debug_mode: configuration.debug_mode
        case level
        when :debug
            logger.debug "[#{context}] #{message}" if debug_mode
        when :info
            logger.info "[#{context}] #{message}"
        when :warn
            logger.warn "[#{context}] #{message}"
        when :error
            logger.error "[#{context}] #{message}"
        end
    end

end