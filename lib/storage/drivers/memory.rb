require 'singleton'

module GenCache
    class Storage
        class Drivers
            class Memory
                include Singleton
                def initialize
                    @cache = {}
                end

                def get item_id
                    # Return a wrapper instance
                    @cache[item_id]
                end
        
                def set item
                    # Take a wrapper instance
                    @cache[item.id] = item
                end
        
                def delete item_id
                    # Delete by ID
                    @cache[item_id] = nil
                end
            end
        end
    end
end