
describe GenCache::Storage::Wrapper do
    describe GenCache::Storage::Wrapper::Metadata do
        describe ".initialize" do
            let(:last_updated) { Time.now }
            let(:generation) { Time.now.to_i }
            it "sets the correct vars" do
                metadata = GenCache::Storage::Wrapper::Metadata.new(last_updated: last_updated, generation: generation)
                assert_equal metadata.last_updated, last_updated
                assert_equal metadata.generation, generation
            end
        end
    end

    describe ".wrap" do
        let(:id) { "abcdef" }
        let(:item) { Minitest::Mock.new }
        let(:logger) { Minitest::Mock.new }

        it "should return a wrapped item" do
            logger.expect :log, nil, [:debug, String, String]
            item.expect :id, id
            wrapped_item = GenCache::Storage::Wrapper.wrap(id, item, logger: logger)
            assert_instance_of GenCache::Storage::Wrapper, wrapped_item
            assert_equal wrapped_item.payload, Oj.dump(item)
        end
    end

    describe ".unwrap" do
        let(:id) { "abcdef" }
        let(:item) { OpenStruct.new(id: id, name: "me") }
        let(:logger) { Minitest::Mock.new }

        it "should unwrap an item" do
            logger.expect :log, nil, [:debug, String, String]
            logger.expect :log, nil, [:debug, String, String]
            wrapped_item = GenCache::Storage::Wrapper.wrap(id, item, logger: logger)

            unwrapped_item = wrapped_item.unwrap(logger: logger)

            assert_equal item, unwrapped_item
        end
    end

    describe ".metadata" do
        let(:id) { "abcdef" }
        let(:item) { OpenStruct.new(id: id, name: "me") }
        let(:logger) { Minitest::Mock.new }

        it "should return metadata for a wrapped item" do
            logger.expect :log, nil, [:debug, String, String]
            logger.expect :log, nil, [:debug, String, String]
            wrapped_item = GenCache::Storage::Wrapper.wrap(id, item, logger: logger)

            assert_instance_of GenCache::Storage::Wrapper::Metadata, wrapped_item.metadata(logger: logger)
        end
    end
end