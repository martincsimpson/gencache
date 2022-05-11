module GenCache
    class Error
        class ItemClassIncorrect < StandardError; end
        class CacheIsOffline < StandardError; end
        class CacheConfigNotFound < StandardError; end
        class ItemNotFound < StandardError; end
        class ItemIsStale < StandardError; end
        class FetchItemsUnexpectedFormat < StandardError; end
    end
end