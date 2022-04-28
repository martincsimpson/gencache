
describe GenCache::Configuration do
    describe ".initialize" do
        let(:cache_configs) { [] }
        let(:debug_mode) { false }
        let(:storage_driver) { Object }
        let(:storage_opts) { {} }
        let(:logger) { Object }

        it "sets the defaults" do
            config = GenCache::Configuration.new
            assert_equal config.cache_configs, []
            assert_equal config.storage_driver, GenCache::Storage::Drivers::Memory
            assert_equal config.storage_opts, {}
            assert_equal config.debug_mode, false
        end

        it "returns a configuration" do
            GenCache.configure do |config|
                 config.cache_configs = cache_configs
                 config.debug_mode = debug_mode
                 config.storage_driver = storage_driver
                 config.storage_opts = storage_opts
                 config.logger = logger
            end

            config = GenCache.configuration
            assert_equal config.cache_configs, cache_configs
            assert_equal config.storage_driver, storage_driver
            assert_equal config.storage_opts, storage_opts
            assert_equal config.debug_mode, debug_mode
        end
    end
end