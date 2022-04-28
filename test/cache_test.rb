describe GenCache::Cache do
    let(:mode) { Minitest::Mock.new }
    let(:storage) { Minitest::Mock.new }
    let(:config) { Minitest::Mock.new }
    let(:namespace) { "namespace" }
    let(:logger) { Minitest::Mock.new }

    describe ".initialize" do

        it "should create mode" do
            logger.expect :log, true, [Object, Object, Object]

            mode.expect :new, mode do |config:|
                 true
            end
            storage.expect :new, storage do |config:, namespace:|
                true
            end
            GenCache::Cache.new(config: config, namespace: namespace, mode: mode, storage: storage, logger: logger)
        end
    end

    describe ".set" do
        let(:cache) { GenCache::Cache.new(config: config, namespace: namespace, mode: mode, storage: storage, logger: logger) }
        let(:cache_item_id) { "id" }
        let(:cache_item) { Minitest::Mock.new }

        it "should call storage set" do
            logger.expect :log, true, [Object, Object, Object]
            logger.expect :log, true, [Object, Object, Object]

            mode.expect :new, mode do |config:|
                true
            end
            storage.expect :new, storage do |config:, namespace:|
                true
            end

            config.expect :item_class, nil
            config.expect :item_class, nil

            cache_item.expect :is_a?, true, [Object]
            storage.expect :set, nil, [String, Object]
            cache.set cache_item_id, cache_item
        end
    end
    describe ".delete" do
        let(:cache) { GenCache::Cache.new(config: config, namespace: namespace, mode: mode, storage: storage, logger: logger) }
        let(:cache_item_id) { "id" }

        it "should call storage delete" do
            logger.expect :log, true, [Object, Object, Object]
            logger.expect :log, true, [Object, Object, Object]

            mode.expect :new, mode do |config:|
                true
            end
            storage.expect :new, storage do |config:, namespace:|
                true
            end

            config.expect :item_class, nil
            config.expect :item_class, nil

            storage.expect :delete, nil, [String]
            cache.delete cache_item_id
        end
    end

end
