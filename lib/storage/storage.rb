module GenCache
    class Storage
        def initialize(config:)
            @config = config
            @driver = GenCache.configuration.storage_driver.instance
            GenCache.log :debug, "storage", "initialized storage with driver: #{@driver}"
        end

        def get item_id
            GenCache.log :debug, "storage", "get #{item_id}"
            @driver.get(item_id)
        end

        def set item
            GenCache.log :debug, "storage", "set #{item.id} #{item}"
            @driver.set(Wrapper.wrap(item))
        end

        def delete item_id
            GenCache.log :debug, "storage", "delete #{item_id}"
            @driver.delete(item_id)
        end
    end
end