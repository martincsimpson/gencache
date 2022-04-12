module GenCache
    class Configuration
        attr_accessor :cache_configs
        attr_accessor :debug_mode
        attr_accessor :storage_driver
        attr_accessor :logger
        
        def initialize
            @cache_configs = []
            @storage_driver = GenCache::Storage::Drivers::Memory
            @debug_mode = false
        end
    end
    
    def self.configuration
        @@configuration
    end
    
    def self.configure
        @@configuration ||= Configuration.new
        yield @@configuration
    end
end