module GenCache
    class Error
        class ItemClassIncorrect < StandardError; end
        class CacheIsOffline < StandardError; end
        class CacheConfigNotFound < StandardError; end
    end
end