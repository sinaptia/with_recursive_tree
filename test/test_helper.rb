require "bundler/setup"

ENV["RAILS_ENV"] = "test"

require "active_record"
require "active_record/testing/query_assertions"
require "active_support"
require "debug"
require "erb"
require "with_recursive_tree"

class ActiveSupport::TestCase
  include ActiveRecord::Assertions::QueryAssertions

  setup do
    @root = Node.create name: "F"

    @b_node = Node.create parent: @root, name: "B"
    @g_node = Node.create parent: @root, name: "G"

    @a_node = Node.create parent: @b_node, name: "A"
    @d_node = Node.create parent: @b_node, name: "D"

    @c_node = Node.create parent: @d_node, name: "C"
    @e_node = Node.create parent: @d_node, name: "E"

    @i_node = Node.create parent: @g_node, name: "I"

    @h_node = Node.create parent: @i_node, name: "H"

    @troot = TextNode.create name: "F"

    @b_tnode = TextNode.create parent: @troot, name: "B"
    @g_tnode = TextNode.create parent: @troot, name: "G"

    @a_tnode = TextNode.create parent: @b_tnode, name: "A"
    @d_tnode = TextNode.create parent: @b_tnode, name: "D"

    @c_tnode = TextNode.create parent: @d_tnode, name: "C"
    @e_tnode = TextNode.create parent: @d_tnode, name: "E"

    @i_tnode = TextNode.create parent: @g_tnode, name: "I"

    @h_tnode = TextNode.create parent: @i_tnode, name: "H"
  end

  teardown do
    [Node, TextNode].each(&:delete_all)
  end
end

adapter = ENV.fetch("DB_ADAPTER", "sqlite3")

file = File.expand_path "database.yml", __dir__
db_config = YAML.safe_load(ERB.new(File.read(file)).result)[adapter]

unless adapter == "sqlite3"
  # make sure we're working on a newly created db
  ActiveRecord::Tasks::DatabaseTasks.drop db_config
  ActiveRecord::Tasks::DatabaseTasks.create db_config
end

ActiveRecord::Base.establish_connection db_config
ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :nodes do |t|
    t.column :name, :string
    t.column :parent_id, :integer

    t.timestamps
  end

  create_table :text_nodes do |t|
    t.column :name, :string
    t.column :parent_node_id, :string

    t.timestamps
  end
end

class Node < ActiveRecord::Base
  with_recursive_tree order: :name
end

class TextNode < ActiveRecord::Base
  with_recursive_tree primary_key: :name, foreign_key: :parent_node_id
end
