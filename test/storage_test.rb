require "test/helper"

describe GenCache::Storage do
    let(:config) { {} }
    let(:namespace) { "namespace" }
    let(:global_config) { Minitest::Mock.new }
    let(:logger) { Minitest::Mock.new }
    let(:storage_driver) { Minitest::Mock.new }

    describe ".initialize" do
        it "should call the driver" do
            global_config.expect :storage_driver, storage_driver
            storage_driver.expect :instance, storage_driver
            storage_driver.expect :set_config, nil, [{ config: config}]
            logger.expect :log, true, [Object, Object, Object]
            GenCache::Storage.new(config: config, namespace: namespace, global_config: global_config, logger: logger, wrapper: nil)

            assert_mock global_config
            assert_mock storage_driver
            assert_mock logger
        end
    end

    describe ".get" do
        before do
            global_config.expect :storage_driver, storage_driver
            storage_driver.expect :instance, storage_driver
            storage_driver.expect :set_config, nil, [{ config: config}]
            logger.expect :log, true, [Object, Object, Object]
        end

        let(:storage) { GenCache::Storage.new(config: config, namespace: namespace, global_config: global_config, logger: logger, wrapper: nil) }

        let(:item_id) { "abcdef" }
        it "should call the driver" do
            logger.expect :log, true, [Object, Object, Object]
            storage_driver.expect :get, nil, [item_id, {namespace: namespace}]
            storage.get(item_id)

            assert_mock storage_driver
            assert_mock logger
        end
    end

    describe ".set" do
        before do
            global_config.expect :storage_driver, storage_driver
            storage_driver.expect :instance, storage_driver
            storage_driver.expect :set_config, nil, [{ config: config}]
            logger.expect :log, true, [Object, Object, Object]
        end
        let(:item_id) { "abcdef" }
        let(:item) { "something" }
        let(:wrapper) { Minitest::Mock.new }
        let(:storage) { GenCache::Storage.new(config: config, namespace: namespace, global_config: global_config, logger: logger, wrapper: wrapper) }

        it "should call the driver" do
            logger.expect :log, true, [Object, Object, Object]
            storage_driver.expect :set, nil, [item_id, item, { namespace: namespace}]
            wrapper.expect :wrap, item, [item_id, item]
            storage.set(item_id, item)

            assert_mock storage_driver
            assert_mock logger
        end
    end

    describe ".delete" do
        before do
            global_config.expect :storage_driver, storage_driver
            storage_driver.expect :instance, storage_driver
            storage_driver.expect :set_config, nil, [{ config: config}]
            logger.expect :log, true, [Object, Object, Object]
        end

        let(:storage) { GenCache::Storage.new(config: config, namespace: namespace, global_config: global_config, logger: logger, wrapper: nil) }

        let(:item_id) { "abcdef" }
        it "should call the driver" do
            logger.expect :log, true, [Object, Object, Object]
            storage_driver.expect :delete, nil, [item_id, {namespace: namespace}]
            storage.delete(item_id)

            assert_mock storage_driver
            assert_mock logger
        end
    end


end