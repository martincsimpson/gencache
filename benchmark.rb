require 'require_all'
require 'benchmark'
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
    config.debug_mode = false
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

number_of_hashes = 10000
keys = 100

hashes = []

number_of_hashes.times do
    h = {}
    keys.times do
        key_id = SecureRandom.hex(10)
        h[key_id] = SecureRandom.hex(255)
    end
    hashes << h
end

Benchmark.bm do |benchmark|
    benchmark.report("Insert 10k") do
        hashes.each do |h|
            GenCache.with_cache("product_cache", namespace: "gstar-enUS").set(h.keys.first, Product.new(id: h.keys.first, name: h))
        end        
    end

    benchmark.report("Get 50k") do
        50_000.times do
            GenCache.with_cache("product_cache", namespace: "gstar-enUS").get(hashes.sample.keys.first)
        end
    end
end