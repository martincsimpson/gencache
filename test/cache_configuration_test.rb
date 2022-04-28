
describe GenCache::Cache::Configuration do
    describe ".initialize" do
        let(:item_name) { "name" }
        let(:item_class) { String }
        let(:control_class) { Object }

        it "sets the vars" do
            config = GenCache::Cache::Configuration.new(name: item_name, item_class: item_class, control_class: control_class)
            assert_equal config.name, item_name
            assert_equal config.item_class, item_class
            assert_equal config.control_class, control_class
        end
    end
end