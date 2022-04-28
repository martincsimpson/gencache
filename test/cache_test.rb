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

    describe ".get" do
        let(:storage) { Minitest::Mock.new }
        let(:control_class) { Minitest::Mock.new }
        let(:item_class) { Class }
        let(:config) { OpenStruct.new(control_class: control_class, item_class: item_class )}
        let(:cache) { GenCache::Cache.new(config: config, namespace: namespace, mode: mode, storage: storage, logger: logger) }
        let(:wrapped_item) { Minitest::Mock.new }
        let(:item_id) { "abcdef" }
        let(:item) { Minitest::Mock.new }
        let(:metadata) { Minitest::Mock.new }
        let(:wrapped_item) { Minitest::Mock.new }

        it "should direct fetch if stale is not allowed and item is stale" do
            mode.expect :new, mode do |config:|
                true
            end
            storage.expect :new, storage do |config:, namespace:|
                true
            end

            storage.expect :get, wrapped_item, [item_id]
            wrapped_item.expect :unwrap, item
            wrapped_item.expect :metadata, metadata
            
            logger.expect :log, nil, [:debug, String, String]

            control_class.expect :stale?, true, [item,metadata]
            control_class.expect :stale_allowed?, false, [item,metadata]

            logger.expect :log, nil, [:debug, String, String]
            logger.expect :log, nil, [:debug, String, String]

            wrapped_item.expect :!, false
            logger.expect :log, nil, [:debug, String, String]

            mode.expect :can_fetch_inline?, true

            control_class.expect :fetch, item, [item_id]
            logger.expect :log, nil, [:debug, String, String]

            logger.expect :log, nil, [:debug, String, String]
            item.expect :is_a?, true, [item_class]

            storage.expect :set, nil, [item_id, item]
            
            cache.get(item_id)
        end

        it "should raise an error if stale and stale not allowed and cache offline" do
            mode.expect :new, mode do |config:|
                true
            end
            storage.expect :new, storage do |config:, namespace:|
                true
            end

            storage.expect :get, wrapped_item, [item_id]
            wrapped_item.expect :unwrap, item
            wrapped_item.expect :metadata, metadata
            
            logger.expect :log, nil, [:debug, String, String]

            control_class.expect :stale?, true, [item,metadata]
            control_class.expect :stale_allowed?, false, [item,metadata]

            logger.expect :log, nil, [:debug, String, String]
            logger.expect :log, nil, [:debug, String, String]

            wrapped_item.expect :!, false
            logger.expect :log, nil, [:debug, String, String]

            mode.expect :can_fetch_inline?, false

            assert_raises GenCache::Error::CacheIsOffline do
                cache.get(item_id)
            end
        end


        it "should return an item if the object is stale and stale is allowed" do
            mode.expect :new, mode do |config:|
                true
            end
            storage.expect :new, storage do |config:, namespace:|
                true
            end

            storage.expect :get, wrapped_item, [item_id]
            wrapped_item.expect :unwrap, item
            wrapped_item.expect :metadata, metadata
            
            logger.expect :log, nil, [:debug, String, String]

            control_class.expect :stale?, true, [item,metadata]
            control_class.expect :stale_allowed?, true, [item,metadata]

            logger.expect :log, nil, [:debug, String, String]
            logger.expect :log, nil, [:debug, String, String]

            wrapped_item.expect :!, false

            control_class.expect :smart_refresh?, false, [item,metadata]
            logger.expect :log, nil, [:debug, String, String]
            logger.expect :log, nil, [:debug, String, String]
            logger.expect :log, nil, [:debug, String, String]

            cache.get(item_id)
        end

        it "should trigger a smart refresh if the right criteria is hit" do
            mode.expect :new, mode do |config:|
                true
            end
            storage.expect :new, storage do |config:, namespace:|
                true
            end

            storage.expect :get, wrapped_item, [item_id]
            wrapped_item.expect :unwrap, item
            wrapped_item.expect :metadata, metadata
            
            logger.expect :log, nil, [:debug, String, String]

            control_class.expect :stale?, true, [item,metadata]
            control_class.expect :stale_allowed?, true, [item,metadata]

            logger.expect :log, nil, [:debug, String, String]
            logger.expect :log, nil, [:debug, String, String]

            wrapped_item.expect :!, false

            control_class.expect :smart_refresh?, true, [item,metadata]
            logger.expect :log, nil, [:debug, String, String]
            logger.expect :log, nil, [:debug, String, String]
            logger.expect :log, nil, [:debug, String, String]

            cache.get(item_id)
        end
    end

    describe ".background_fetch" do
        let(:storage) { Minitest::Mock.new }
        let(:control_class) { Minitest::Mock.new }
        let(:item_class) { Class }
        let(:config) { OpenStruct.new(control_class: control_class, item_class: item_class )}
        let(:cache) { GenCache::Cache.new(config: config, namespace: namespace, mode: mode, storage: storage, logger: logger) }
        let(:wrapped_item) { Minitest::Mock.new }
        let(:item_id) { "abcdef" }
        let(:item) { Minitest::Mock.new }
        let(:metadata) { Minitest::Mock.new }
        let(:wrapped_item) { Minitest::Mock.new }

        it "should call direct fetch" do
            mode.expect :new, mode do |config:|
                true
            end
            storage.expect :new, storage do |config:, namespace:|
                true
            end
            logger.expect :log, nil, [:debug, String, String]
            mode.expect :can_fetch_background?, true

            cache.stub :direct_fetch, nil do
                cache.background_fetch item_id
            end
        end

        it "should call raise an error if cache is offline" do
            mode.expect :new, mode do |config:|
                true
            end
            storage.expect :new, storage do |config:, namespace:|
                true
            end
            logger.expect :log, nil, [:debug, String, String]
            mode.expect :can_fetch_background?, false
            
            cache.stub :direct_fetch, nil do
                assert_raises GenCache::Error::CacheIsOffline do
                    cache.background_fetch item_id
                end
            end
        end

    end
end
