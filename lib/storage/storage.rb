module GenCache
    class Storage
        def initialize(config:)
            @config = config
            @driver = GenCache.configuration.storage_driver.instance
        end

        def get item_id
            @driver.get(item_id)
        end

        def set item
            @driver.set(Wrapper.wrap(item))
        end

        def delete item_id
            @driver.delete(item_id)
        end
    end
end