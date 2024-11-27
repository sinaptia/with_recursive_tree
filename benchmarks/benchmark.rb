require "bundler/setup"

require "active_record"
require "active_record/testing/query_assertions"
require "active_support"
require "acts_as_tree"
require "ancestry"
require "benchmark"
require "closure_tree"
require "debug"

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

begin
  stdout = $stdout
  $stdout = StringIO.new

  ActiveRecord::Schema.define do
    create_table :a_categories do |t|
      t.column :ancestry, :string
      t.index :ancestry
    end

    create_table :aat_categories do |t|
      t.column :parent_id, :integer
      t.index :parent_id
    end

    create_table :ct_categories do |t|
      t.column :parent_id, :integer
      t.index :parent_id
    end

    create_table :ct_category_hierarchies, id: false do |t|
      t.column :ancestor_id, :integer, null: false
      t.column :descendant_id, :integer, null: false
      t.column :generations, :integer, null: false
    end

    create_table :wrt_categories do |t|
      t.column :parent_id, :integer
      t.index :parent_id
    end
  end
ensure
  $stdout = stdout
end

class ACategory < ActiveRecord::Base
  has_ancestry
end

class AatCategory < ActiveRecord::Base
  include ActsAsTree

  acts_as_tree
end

class CtCategory < ActiveRecord::Base
  has_closure_tree
end

require "with_recursive_tree"

class WrtCategory < ActiveRecord::Base
  with_recursive_tree
end

def create_tree(klass, parent = nil, level = 0, max_levels = 3, siblings = 2)
  return if level > max_levels

  siblings.times do
    node = klass.create parent: parent

    create_tree klass, node, level + 1, max_levels
  end
end

levels = [3, 5, 7, 10, 12, 14]
siblings = [2, 3, 4, 5, 6, 7, 8, 9, 10]

levels.product(siblings).each do |max_levels, max_siblings|
  a_root = ACategory.create
  create_tree ACategory, a_root, 0, max_levels, max_siblings

  aat_root = AatCategory.create
  create_tree AatCategory, aat_root, 0, max_levels, max_siblings

  ct_root = CtCategory.create
  create_tree CtCategory, ct_root, 0, max_levels, max_siblings

  wrt_root = WrtCategory.create
  create_tree WrtCategory, wrt_root, 0, max_levels, max_siblings

  Benchmark.bm do |x|
    x.report("#{max_levels} levels, #{max_siblings} siblings | ::roots | ANC") { ACategory.roots.count }
    x.report("#{max_levels} levels, #{max_siblings} siblings | ::roots | AAT") { AatCategory.roots.count }
    x.report("#{max_levels} levels, #{max_siblings} siblings | ::roots | CLT") { CtCategory.roots.count }
    x.report("#{max_levels} levels, #{max_siblings} siblings | ::roots | WRT") { WrtCategory.roots.count }

    x.report("#{max_levels} levels, #{max_siblings} siblings | #ancestors | ANC") { ACategory.last.ancestors.count }
    x.report("#{max_levels} levels, #{max_siblings} siblings | #ancestors | AAT") { AatCategory.last.ancestors.count }
    x.report("#{max_levels} levels, #{max_siblings} siblings | #ancestors | CLT") { CtCategory.last.ancestors.count }
    x.report("#{max_levels} levels, #{max_siblings} siblings | #ancestors | WRT") { WrtCategory.last.ancestors.count }

    x.report("#{max_levels} levels, #{max_siblings} siblings | #descendants | ANC") { a_root.descendants.count }
    x.report("#{max_levels} levels, #{max_siblings} siblings | #descendants | AAT") { aat_root.descendants.count }
    x.report("#{max_levels} levels, #{max_siblings} siblings | #descendants | CLT") { ct_root.descendants.count }
    x.report("#{max_levels} levels, #{max_siblings} siblings | #descendants | WRT") { wrt_root.descendants.count }

    x.report("#{max_levels} levels, #{max_siblings} siblings | #level | ANC") { ACategory.last.level }
    x.report("#{max_levels} levels, #{max_siblings} siblings | #level | AAT") { AatCategory.last.level }
    x.report("#{max_levels} levels, #{max_siblings} siblings | #level | CLT") { CtCategory.last.level }
    x.report("#{max_levels} levels, #{max_siblings} siblings | #level | WRT") { WrtCategory.last.level }

    x.report("#{max_levels} levels, #{max_siblings} siblings | #root | ANC") { ACategory.last.root }
    x.report("#{max_levels} levels, #{max_siblings} siblings | #root | AAT") { AatCategory.last.root }
    x.report("#{max_levels} levels, #{max_siblings} siblings | #root | CLT") { CtCategory.last.root }
    x.report("#{max_levels} levels, #{max_siblings} siblings | #root | WRT") { WrtCategory.last.root }

    x.report("#{max_levels} levels, #{max_siblings} siblings | #self_and_ancestors | ANC") { ACategory.last.path }
    x.report("#{max_levels} levels, #{max_siblings} siblings | #self_and_ancestors | AAT") { AatCategory.last.self_and_ancestors }
    x.report("#{max_levels} levels, #{max_siblings} siblings | #self_and_ancestors | CLT") { CtCategory.last.self_and_ancestors }
    x.report("#{max_levels} levels, #{max_siblings} siblings | #self_and_ancestors | WRT") { WrtCategory.last.self_and_ancestors }

    x.report("#{max_levels} levels, #{max_siblings} siblings | #self_and_descendants | ANC") { a_root.subtree.count }
    x.report("#{max_levels} levels, #{max_siblings} siblings | #self_and_descendants | AAT") { aat_root.self_and_descendants.count }
    x.report("#{max_levels} levels, #{max_siblings} siblings | #self_and_descendants | CLT") { ct_root.self_and_descendants.count }
    x.report("#{max_levels} levels, #{max_siblings} siblings | #self_and_descendants | WRT") { wrt_root.self_and_descendants.count }

    x.report("#{max_levels} levels, #{max_siblings} siblings | #self_and_siblings | ANC") { a_root.children.first.siblings }
    x.report("#{max_levels} levels, #{max_siblings} siblings | #self_and_siblings | AAT") { aat_root.children.first.self_and_siblings }
    x.report("#{max_levels} levels, #{max_siblings} siblings | #self_and_siblings | CLT") { ct_root.children.first.self_and_siblings }
    x.report("#{max_levels} levels, #{max_siblings} siblings | #self_and_siblings | WRT") { wrt_root.children.first.self_and_siblings }
  end
end
