module GenCache
    class Storage
        def initialize(config:, namespace:)
            @config = config
            @driver = GenCache.configuration.storage_driver.instance
            @namespace = namespace
            GenCache.log :debug, "storage", "initialized storage with driver: #{@driver} in namespace: #{@namespace}"
        end

        def get item_id
            GenCache.log :debug, "storage", "get #{item_id}"
            @driver.get(item_id, namespace: @namespace)
        end

        def set id, item
            GenCache.log :debug, "storage", "set #{id} #{item}"
            @driver.set(Wrapper.wrap(id, item), namespace: @namespace)
        end

        def delete item_id
            GenCache.log :debug, "storage", "delete #{item_id}"
            @driver.delete(item_id, namespace: @namespace)
        end
    end
end