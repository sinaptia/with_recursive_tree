require_relative "helper"

require "closure_tree"

silence do
  ActiveRecord::Schema.define do
    create_table :nodes do |t|
      t.column :parent_id, :integer
      t.column :sort, :integer
      t.index :parent_id
    end

    create_table :node_hierarchies, id: false do |t|
      t.column :ancestor_id, :integer, null: false
      t.column :descendant_id, :integer, null: false
      t.column :generations, :integer, null: false
    end
  end
end

class Node < ActiveRecord::Base
  has_closure_tree order: :sort, numeric_order: true
end

levels, siblings = ARGV[0].to_i, ARGV[1].to_i

create_tree Node.create, 0, levels, siblings

Benchmark.bmbm do |x|
  x.report("::roots") { Node.roots.all }
  x.report("#ancestors") { Node.last.ancestors.all }
  x.report("#descendants") { Node.roots.first.descendants.all }
  x.report("#level") { Node.last.level }
  x.report("#root") { Node.last.root }
  x.report("#self_and_ancestors") { Node.last.self_and_ancestors.all }
  x.report("#self_and_descendants") { Node.roots.first.self_and_descendants.all }
  x.report("#self_and_siblings") { Node.roots.first.reload.children.first.self_and_siblings }
  x.report("walk tree, dfs") do
    Node.roots.first.self_and_descendants_preordered.each { |node| silence { puts "#{node.id} (#{node.level})" } }
  end
  x.report("reparenting") do
    root = Node.roots.first
    first_child = root.children.first
    first_grandchild = first_child.children.first

    # move the first grandchild to be a child of the root node
    first_grandchild.update parent: root
  end
end
