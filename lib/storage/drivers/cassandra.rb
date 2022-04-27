require 'singleton'
require 'cassandra'

# CREATE KEYSPACE gencache WITH replication = {
#     'class': 'NetworkTopologyStrategy', 
#     'europe-west3': '3', 
#     'europe-west4': '3', 
#     'us-central1': '3', 
#     'us-east1': '3'
# };

# CREATE TABLE gencache.cache (
#     cache_id text,
#     namespace text,
#     id text,
#     created_at timestamp,
#     generation bigint,
#     data text,
#     PRIMARY KEY ((cache_id, namespace, id))
# )

module GenCache
    class Storage
        class Drivers
            class Cassandra
                include Singleton

                KEYSPACE="gencache"
                TABLE="cache"

                KEYSPACE_DEFINITION="""
                CREATE KEYSPACE gencache WITH replication = {
                    'class': 'NetworkTopologyStrategy', 
                    'datacenter1': '3'
                };                
                """

                TABLE_DEFINITION="""
                CREATE TABLE gencache.cache (
                    cache_id text,
                    namespace text,
                    id text,
                    created_at timestamp,
                    generation bigint,
                    data text,
                    PRIMARY KEY ((cache_id, namespace, id))
                )
                """

                def initialize
                    @cache = {}
                    cluster = ::Cassandra.cluster(hosts: GenCache.configuration.storage_opts[:host])

                    begin
                        @session = cluster.connect(KEYSPACE)
                    rescue ::Cassandra::Errors::InvalidError
                        @session = cluster.connect
                        create_keyspace_and_table
                        @session = cluster.connect(KEYSPACE)
                    end
                end

                def set_config(config:)
                    @config = config
                end

                def get item_id, namespace:
                    attributes = {
                        cache_id: @config.name,
                        namespace: namespace,
                        id: item_id
                    }

                    selector_string = build_selector(attributes)
                    selector_string.prepend(" where ") unless selector_string.empty?              
                    query = "SELECT * from %<table>s %<selector_string>s" % { table: TABLE, selector_string: selector_string}

                    result = @session.execute(query, arguments: attributes)

                    wrapper = Wrapper.new
                    wrapper.id = result.rows.first["id"]
                    wrapper.generation = result.rows.first["generation"]
                    wrapper.last_updated = result.rows.first["created_at"]
                    wrapper.payload = result.rows.first["data"]

                    wrapper
                end
        
                def set id, item, namespace:
                    # Take a wrapper instance
                    attributes = {
                        cache_id: @config.name,
                        namespace: namespace,
                        id: id,
                        created_at: Time.now.to_i,
                        generation: Time.now.to_i,
                        data: item.payload
                    }

                    query = "INSERT INTO %<table>s (%<keys>s) VALUES (%<values>s)" % {table: TABLE, keys: attributes.keys.join(","), values: attributes.keys.map { "?" }.join(",")}
                    result = @session.execute(query, arguments: attributes)
                end

                def update_ttl item, ttl
                    # TODO
                    raise NotImplementedError
                end
        
                def delete item_id, namespace:
                    # Delete by ID
                    query = "DELETE from %<table>s WHERE cache_id = '%<cache_id>s' AND where namespace = '%<namespace>s AND where id = '%<id>s''" % { table: TABLE, cache_id: @config.name, namespace: namespace, id: item_id}
                    result = @session.execute(query)
                end

                private

                def create_keyspace_and_table
                    @session.execute(KEYSPACE_DEFINITION)
                    @session.execute(TABLE_DEFINITION)
                end

                def build_selector(attributes)
                    attributes.map do |k,v|
                        if v.is_a?(Array)
                            "%<key>s IN ('%<values>s')" % { key: k, values: v.join("','")}
                        else
                            "%<key>s = ?" % { key: k }
                        end
                    end.join(" AND ")
                end
            end
        end
    end
end