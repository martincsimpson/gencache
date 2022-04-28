module GenCache
    class Cache
        class Mode
            def initialize(config:)
                @config = config
            end

            # Inline fetches are allowed unless we are in state offline
            def can_fetch_inline?(logger: GenCache)
                logger.log :debug, "mode_can_fetch_inline", "cache_mode: #{@config.control_class.cache_mode}"
                return false if @config.control_class.cache_mode == :offline
                true
            end

            # Background fetches are only allowed in the case that we are in
            # normal cache mode
            def can_fetch_background?(logger: GenCache)
                logger.log :debug, "mode_can_fetch_background", "cache_mode: #{@config.control_class.cache_mode}"
                return true if @config.control_class.cache_mode == :normal
                false
            end
        end
    end
end