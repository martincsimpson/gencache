require 'simplecov'            # These two lines must go first
SimpleCov.start

require 'minitest'
require 'minitest/autorun'

require "lib/gencache.rb"
require "lib/error.rb"
require "lib/cache.rb"

describe GenCache do
    describe ".with_cache" do
        let(:cache_name) { "test_cache" }
        let(:namespace) { "test_namespace" }
        let(:configs) { [OpenStruct.new(name: cache_name)] }
        let(:logger) { Minitest::Mock.new }

        it "shoud return a cache" do
            logger.expect :log, true, [Object, Object, Object]

            GenCache::Cache.stub :new, OpenStruct.new do
                cache = GenCache.with_cache(cache_name, namespace: namespace, logger: logger, configs: configs)
                assert_instance_of OpenStruct, cache
            end
        end

        describe "no configs" do
            let(:configs) { [] }

            it "should raise an error if cache config not found" do
                logger.expect :log, true, [Object, Object, Object]
    
                assert_raises GenCache::Error::CacheConfigNotFound do
                    cache = GenCache.with_cache(cache_name, namespace: namespace, logger: logger, configs: configs)
                end
            end
        end
    end

    describe ".log" do
        let(:logger) { Minitest::Mock.new }

        describe "debug mode" do

            it "should log debug messages" do
                logger.expect :debug, nil, [String]
                GenCache.log :debug, "something", "somewhere", logger: logger, debug_mode: true
                assert_mock logger
            end
        end

        describe "not debug mode" do
            it "should log not log out a debug message" do
                GenCache.log :debug, "something", "somewhere", logger: logger, debug_mode: false
                assert_mock logger
            end
            it "should log a info message" do
                logger.expect :info, nil, [String]
                GenCache.log :info, "something", "somewhere", logger: logger, debug_mode: false
                assert_mock logger
            end
            it "should log a warn message" do
                logger.expect :warn, nil, [String]
                GenCache.log :warn, "something", "somewhere", logger: logger, debug_mode: false
                assert_mock logger
            end
            it "should log a error message" do
                logger.expect :error, nil, [String]
                GenCache.log :error, "something", "somewhere", logger: logger, debug_mode: false
                assert_mock logger
            end
        end
    end

end

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

end
