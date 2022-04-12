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
    
    # Fetches item from an external source
    def self.fetch item_id
        # This is sample code
        item = Product.new
        item.id = item_id
        item.name = "Product Name - #{item_id}"

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
        return true
    end
end

GenCache.configure do |config|
    config.debug_mode = true
    config.storage_driver = GenCache::Storage::Drivers::Memory
    config.logger = Logger.new(STDOUT)
    config.cache_configs << GenCache::Cache::Configuration.new(
        name: "product_cache",
        bucket_key: "merchant",
        item_class: Product,
        control_class: ProductCacheControl,
    )
end
GenCache.with_cache("product_cache").set(Product.new(id: "test", name: "test product"))
GenCache.with_cache("product_cache").get("test")