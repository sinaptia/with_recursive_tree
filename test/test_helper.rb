require "bundler/setup"

require "active_record"
require "active_record/testing/query_assertions"
require "active_support"
require "debug"
require "with_recursive_tree"

class ActiveSupport::TestCase
  include ActiveRecord::Assertions::QueryAssertions

  setup do
    @root = Category.create
    @second_root = Category.create

    @level1_1 = Category.create parent: @root
    @level1_2 = Category.create parent: @root
    @level1_3 = Category.create parent: @root

    @level1_1_a = Category.create parent: @level1_1
    @level1_1_b = Category.create parent: @level1_1
    @level1_1_c = Category.create parent: @level1_1

    @level1_2_a = Category.create parent: @level1_2
    @level1_2_b = Category.create parent: @level1_2

    @level1_1_a_1 = Category.create parent: @level1_1_a
    @level1_1_a_2 = Category.create parent: @level1_1_a

    @level1_1_b_1 = Category.create parent: @level1_1_b

    @thing_root = Thing.create thing_id: "thing root"

    @thing_level1_1 = Thing.create parent: @thing_root, thing_id: "thing level 1.1"
    @thing_level1_2 = Thing.create parent: @thing_root, thing_id: "thing level 1.2"

    @thing_level1_1_a = Thing.create parent: @thing_level1_1, thing_id: "thing level 1.1.a"
    @thing_level1_1_b = Thing.create parent: @thing_level1_1, thing_id: "thing level 1.1.b"

    @thing_level1_2_a = Thing.create parent: @thing_level1_2, thing_id: "thing level 1.2.a"
    @thing_level1_2_b = Thing.create parent: @thing_level1_2, thing_id: "thing level 1.2.b"

    @thing_level1_1_a_1 = Thing.create parent: @thing_level1_1_a, thing_id: "thing level 1.1.a.1"
  end

  teardown do
    [Category, Thing].each(&:delete_all)
  end
end

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

begin
  stdout = $stdout
  $stdout = StringIO.new

  ActiveRecord::Schema.define do
    create_table :categories do |t|
      t.column :parent_id, :integer
    end

    create_table :things do |t|
      t.column :parent_thing_id, :string
      t.column :thing_id, :string
    end
  end
ensure
  $stdout = stdout
end

class Category < ActiveRecord::Base
  with_recursive_tree
end

class Thing < ActiveRecord::Base
  with_recursive_tree primary_key: :thing_id, foreign_key: :parent_thing_id
end
