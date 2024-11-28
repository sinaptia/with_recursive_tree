require "test_helper"

class SelfAndDescedantsTest < ActiveSupport::TestCase
  test "performs only one query" do
    assert_queries_count(1) { @root.self_and_descendants.count }
  end

  test "returns an ActiveRecord::Relation" do
    assert_kind_of ActiveRecord::Relation, @root.self_and_descendants
  end

  test "the collection returns self and the descendants" do
    assert_equal @d_node.self_and_descendants, [@d_node, @c_node, @e_node]
  end
end
