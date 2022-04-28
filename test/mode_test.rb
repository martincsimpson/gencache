describe GenCache::Cache::Mode do
    describe ".initialize" do
        it "sets the config" do
            GenCache::Cache::Mode.new(config: {})
        end
    end

    describe "cache is offline" do
        let(:control_class) { OpenStruct.new(cache_mode: :offline )}
        let(:config) { OpenStruct.new(control_class: control_class)}
        let(:logger) { Minitest::Mock.new }
        
        it "should not allow inline fetch" do
            logger.expect :log, nil, [:debug, String, String]
            mode = GenCache::Cache::Mode.new(config: config)
            assert_equal false, mode.can_fetch_inline?(logger: logger)
        end

        it "should not allow background fetch" do
            logger.expect :log, nil, [:debug, String, String]
            mode = GenCache::Cache::Mode.new(config: config)
            assert_equal false, mode.can_fetch_background?(logger: logger)
        end
    end

    describe "cache is normal" do
        let(:control_class) { OpenStruct.new(cache_mode: :normal )}
        let(:config) { OpenStruct.new(control_class: control_class)}
        let(:logger) { Minitest::Mock.new }
        
        it "should allow inline fetch" do
            logger.expect :log, nil, [:debug, String, String]
            mode = GenCache::Cache::Mode.new(config: config)
            assert_equal true, mode.can_fetch_inline?(logger: logger)
        end

        it "should allow background fetch" do
            logger.expect :log, nil, [:debug, String, String]
            mode = GenCache::Cache::Mode.new(config: config)
            assert_equal true, mode.can_fetch_background?(logger: logger)
        end
    end

    describe "cache is degraded" do
        let(:control_class) { OpenStruct.new(cache_mode: :degraded )}
        let(:config) { OpenStruct.new(control_class: control_class)}
        let(:logger) { Minitest::Mock.new }
        
        it "should allow inline fetch" do
            logger.expect :log, nil, [:debug, String, String]
            mode = GenCache::Cache::Mode.new(config: config)
            assert_equal true, mode.can_fetch_inline?(logger: logger)
        end

        it "should not allow background fetch" do
            logger.expect :log, nil, [:debug, String, String]
            mode = GenCache::Cache::Mode.new(config: config)
            assert_equal false, mode.can_fetch_background?(logger: logger)
        end
    end

end