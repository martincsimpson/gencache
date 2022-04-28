
describe GenCache::Storage::Drivers::Memory do
    describe ".set" do
        let(:driver) { GenCache::Storage::Drivers::Memory.instance }
        let(:id) { "abcdef" }
        let(:item) { OpenStruct.new(id: id )}
        let(:namespace) { "namespace" }

        it "sets an item" do
            driver.set id, item, namespace: namespace
            assert_equal item, driver.get(id, namespace: namespace)
        end

        it "deletes an item" do
            driver.delete id, namespace: namespace
            assert_equal nil, driver.get(id, namespace: namespace)
        end

    end
end