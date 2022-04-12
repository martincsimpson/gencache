module GenCache
    class Cache
        class Configuration
            attr_accessor :name
            attr_accessor :bucket_key
            attr_accessor :item_class
            attr_accessor :control_class

            def initialize(name:, bucket_key:, item_class:, control_class:)
                @name = name
                @bucket_key = bucket_key
                @item_class = item_class
                @control_class = control_class
            end
        end
    end
end