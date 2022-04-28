
describe GenCache::Cache::BackgroundFetcher do
    describe ".perform" do
        let(:cache_name) { "test_cache" }
        let(:item_id) { "abcdef" }
        let(:cache) { Minitest::Mock.new }

        it "calls the background fetch method" do
            cache.expect :log, nil, [:info, String, String]
            cache.expect :with_cache, cache, [cache_name]
            cache.expect :background_fetch, nil, [item_id]
            GenCache::Cache::BackgroundFetcher.new.perform(cache_name, item_id, cache: cache)

            assert_mock cache
        end
    end
end