require_relative "helper"

require "ancestry"

silence do
  ActiveRecord::Schema.define do
    create_table :nodes do |t|
      t.column :ancestry, :string
      t.index :ancestry
    end
  end
end

class Node < ActiveRecord::Base
  has_ancestry
end

levels, siblings = ARGV[0].to_i, ARGV[1].to_i

create_tree Node.create, 0, levels, siblings

Benchmark.bmbm do |x|
  x.report("::roots") { Node.roots.all }
  x.report("#ancestors") { Node.last.ancestors.all }
  x.report("#descendants") { Node.roots.first.descendants.all }
  x.report("#level") { Node.last.depth }
  x.report("#root") { Node.last.root }
  x.report("#self_and_ancestors") { Node.last.path.all }
  x.report("#self_and_descendants") { Node.roots.first.subtree.all }
  x.report("#self_and_siblings") { Node.roots.first.children.first.siblings }
  x.report("walk tree, dfs") do
    Node.sort_by_ancestry(Node.roots.first.subtree).each { |node| silence { puts "#{node.id} (#{node.depth})" } }
  end
end
