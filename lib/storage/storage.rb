module GenCache
    class Storage
        def initialize(config:, namespace:, global_config: GenCache.configuration, logger: GenCache, wrapper: Wrapper)
            @logger = logger
            @wrapper = wrapper
            @driver = global_config.storage_driver.instance
            @driver.set_config(config: config)
            @namespace = namespace
            @logger.log :debug, "storage", "initialized storage with driver: #{@driver} in namespace: #{@namespace}"
        end

        def get item_id
            @logger.log :debug, "storage", "get #{item_id}"
            @driver.get(item_id, namespace: @namespace)
        end

        def set id, item
            @logger.log :debug, "storage", "set #{id} #{item}"
            @driver.set(id, @wrapper.wrap(id, item), namespace: @namespace)
        end

        def delete item_id
            @logger.log :debug, "storage", "delete #{item_id}"
            @driver.delete(item_id, namespace: @namespace)
        end
    end
end