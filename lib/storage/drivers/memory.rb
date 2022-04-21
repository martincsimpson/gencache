require 'singleton'

module GenCache
    class Storage
        class Drivers
            class Memory
                include Singleton
                def initialize
                    @cache = {}
                end

                def set_config(config:)
                    # NOOP
                end

                def get item_id, namespace:
                    # Return a wrapper instance
                    @cache[item_id]
                end
        
                def set id, item, namespace:
                    # Take a wrapper instance
                    @cache[id] = item
                end
        
                def delete item_id, namespace:
                    # Delete by ID
                    @cache[item_id] = nil
                end
            end
        end
    end
end