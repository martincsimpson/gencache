require 'require_all'
require_all "./lib"

class Product
    attr_accessor :id
    attr_accessor :name

    MAX_STALE_TIME=600

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
    def fetch item_id
        # This is sample code
        item = Product.new
        item.id = item_id
        item.name = "Product Name - #{item_id}"

        raise GenCache::Error::ItemNotFound unless item

        return item
    end

    def smart_refresh? item
        if rand(1..10) % 2 == 1
            return true
        else
            return false
        end
    end

    # TODO: Dependent on metadata
    def stale? item, current_age
        if stock > 10
            return true
        end
    end

    def stale_allowed? item # HS::Product
        if item.stock > 1
            return true
        else
            return false
        end
    end
end

GenCache.configure do |config|
    config.debug_mode = true
    config.cache_configs << GenCache::Cache::Configuration.new(
        name: "product_cache",
        bucket_key: "merchant",
        item_class: Product,
        control_class: ProductCacheControl,
        storage_driver: GenCache::Storage::Drivers::Memory
    )
end

GenCache.with_cache("product_cache").get(item_id)
GenCache.with_cache("product_cache").set(item_id, object)