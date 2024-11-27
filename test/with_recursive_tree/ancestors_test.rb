require "test_helper"

class AncestorsTest < ActiveSupport::TestCase
  test "returns an ActiveRecord::Relation" do
    assert_kind_of ActiveRecord::Relation, @root.ancestors
  end

  test "a root node has no ancestors" do
    assert_empty @root.ancestors
  end

  test "other nodes have at least one ancestor" do
    assert_not_empty @level1_1_a_2.ancestors
  end

  test "performs only one query" do
    assert_queries_count(1) { @level1_1_a_2.ancestors.count }
  end

  test "it doesn't contain the node" do
    assert_not_includes @level1_1_a_2.ancestors, @level1_1_a_2
  end
end
