require "test_helper"

class AncestorsTest < ActiveSupport::TestCase
  test "returns an ActiveRecord::Relation" do
    assert_kind_of ActiveRecord::Relation, @root.ancestors
  end

  test "a root node has no ancestors" do
    assert_empty @root.ancestors
  end

  test "other nodes have at least one ancestor" do
    assert_not_empty @a_node.ancestors
  end

  test "performs only one query" do
    assert_queries_count(1) { @a_node.ancestors.count }
  end

  test "it doesn't contain the node" do
    assert_not_includes @a_node.ancestors, @a_node
  end
end
