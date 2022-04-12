module GenCache
    class Storage
        def initialize(config:)
            @config = config
            @driver = @config.storage_driver.new
        end

        def get item_id
            raw_item = @driver.get(item_id)
            item = raw_item.unwrap

            item, raw_item.stale?
        end

        def set item
            item = Wrapper.wrap(item)
            @driver.set(item)
        end

        def delete item_id
            @driver.delete(item_id)
        end
    end
end