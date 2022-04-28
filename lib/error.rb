module GenCache
    class Error
        class ItemClassIncorrect < StandardError; end
        class CacheIsOffline < StandardError; end
        class CacheConfigNotFound < StandardError; end
        class ItemNotFound < StandardError; end
    end
end