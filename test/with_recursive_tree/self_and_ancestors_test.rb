require "test_helper"

class SelfAndAncestorsTest < ActiveSupport::TestCase
  test "performs only one query" do
    assert_queries_count(1) { @c_node.self_and_ancestors.count }
  end

  test "returns an ActiveRecord::Relation" do
    assert_kind_of ActiveRecord::Relation, @c_node.self_and_ancestors
  end

  test "the collection returns self and the ancestors" do
    assert_equal @c_node.self_and_ancestors, [@c_node, @d_node, @b_node, @root]
  end
end
