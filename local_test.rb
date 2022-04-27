require 'require_all'
require_all "./lib"

class Product
    attr_accessor :id
    attr_accessor :name

    MAX_STALE_TIME=600

    def initialize id:, name:
        @id = id
        @name = name
    end

    def to_hash
        {
            id: @id,
            name: @name
        }
    end
end

# Highstreet interface to the cache
class ProductCacheControl
    # TODO: This cache mode should probably be internalised
    # via an api so we can call GenCache.with_cache("cache").cache_mode.offline!
    # instead of doing it via the control class
    def self.cache_mode
        :offline
    end

    # Fetches item from an external source
    def self.fetch item_id
        # This is sample code
        item = Product.new(id: item_id, name: "Product Name - #{item_id}")
        raise GenCache::Error::ItemNotFound unless item

        return item
    end

    def self.smart_refresh? item, metadata
        if rand(1..10) % 2 == 1
            return true
        else
            return false
        end
    end

    # TODO: Dependent on metadata
    def self.stale? item, metadata
        return false
    end

    def self.stale_allowed? item, metadata
        return false
    end
end

GenCache.configure do |config|
    config.debug_mode = true
    # config.storage_driver = GenCache::Storage::Drivers::Memory
    config.storage_driver = GenCache::Storage::Drivers::Cassandra
    config.storage_opts = {
        host: "192.168.195.128"
    }
    config.logger = Logger.new(STDOUT)
    config.cache_configs << GenCache::Cache::Configuration.new(
        name: "product_cache",
        item_class: Product,
        control_class: ProductCacheControl,
    )
end

GenCache.with_cache("product_cache", namespace: "gstar-enUS").set("test111", Product.new(id: "test", name: "test product"))
GenCache.with_cache("product_cache", namespace: "gstar-enUS").get("test111")