module GenCache
    class Storage
        class Wrapper
            attr_accessor :id
            attr_accessor :generation
            attr_accessor :last_updated
            attr_accessor :payload

            def self.wrap(item)
                wrapped_item = Wrapper.new
                wrapped_item.id = item.id
                wrapped_item.generation = Time.now.to_i
                wrapped_item.payload = item.to_hash
                wrapped_item
            end

            def unwrap
                # Rehydrate against the config class
            end

            def stale?
                # Determine if the item is stale based on the last updated time and max age for the item
            end
        end
    end
end