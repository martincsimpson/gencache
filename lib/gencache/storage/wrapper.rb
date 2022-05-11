require 'oj'

module GenCache
    class Storage
        class Wrapper
            class Metadata
                attr_reader :last_updated
                attr_reader :generation

                def initialize(last_updated:, generation:)
                    @last_updated = last_updated
                    @generation = generation
                end
            end

            attr_accessor :id
            attr_accessor :generation
            attr_accessor :last_updated
            attr_accessor :payload
        
            def self.wrap(id, item, logger: GenCache)
                logger.log :debug, "wrapper", "wrapping item #{item} #{item.id}"
                wrapped_item = Wrapper.new
                wrapped_item.id = id
                wrapped_item.generation = Time.now.to_i
                wrapped_item.payload = Oj.dump(item)
                wrapped_item
            end

            def unwrap(logger: GenCache)
                logger.log :debug, "wrapper", "unwrapping #{@payload}"
                Oj.load(@payload)
            end

            def metadata(logger: GenCache)
                logger.log :debug, "wrapper", "creating metadata last_updated: #{@last_updated} generation: #{@generation}"
                Metadata.new(last_updated: @last_updated, generation: @generation)
            end


        end
    end
end