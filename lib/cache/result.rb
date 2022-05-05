module GenCache
    class Cache
        class Result
            attr_accessor :id
            attr_accessor :status
            attr_accessor :error
            attr_accessor :item

            def success?
                status != :error
            end
        
            def self.missing! item_id
                result = Result.new
                result.status = :error
                result.item = nil
                result.error = GenCache::Error::ItemNotFound.new
                result.id = item_id
                result
            end

            def self.stale_not_ok! item_id, item
                result = Result.new
                result.status = :error
                result.item = item
                result.error = GenCache::Error::ItemIsStale.new
                result.id = item_id
                result
            end

            def self.stale_ok! item_id, item
                result = Result.new
                result.status = :stale
                result.item = item
                result.error = nil
                result.id = item_id
                result
            end

            def self.ok! item_id, item
                result = Result.new
                result.status = :active
                result.item = item
                result.error = nil
                result.id = item_id
                result
            end

            def self.error! item_id, error
                result = Result.new
                result.status = :error
                result.item = nil
                result.error = error
                result.id = item_id
                result
            end

        end
    end
end