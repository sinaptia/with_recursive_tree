require_relative "helper"

require "acts_as_tree"

silence do
  ActiveRecord::Schema.define do
    create_table :nodes do |t|
      t.column :parent_id, :integer
      t.index :parent_id
    end
  end
end

class Node < ActiveRecord::Base
  include ActsAsTree
  extend ActsAsTree::TreeWalker

  acts_as_tree
end

levels, siblings = ARGV[0].to_i, ARGV[1].to_i

create_tree Node.create, 0, levels, siblings

Benchmark.bmbm do |x|
  x.report("::roots") { Node.roots.all }
  x.report("#ancestors") { Node.last.ancestors }
  x.report("#descendants") { Node.roots.first.descendants }
  x.report("#level") { Node.last.level }
  x.report("#root") { Node.last.root }
  x.report("#self_and_ancestors") { Node.last.self_and_ancestors }
  x.report("#self_and_descendants") { Node.roots.first.self_and_descendants }
  x.report("#self_and_siblings") { Node.roots.first.children.first.self_and_siblings }
  x.report("walk tree, dfs") do
    Node.roots.first.walk_tree { |node, level| silence { puts "#{node.id} (#{node.level})" } }
  end
  x.report("walk tree, bfs") do
    Node.roots.first.walk_tree(algorithm: :bfs) { |node, level| silence { puts "#{node.id} (#{node.level})" } }
  end
end
