require "test_helper"

class DescendantsTest < ActiveSupport::TestCase
  test "returns an ActiveRecord::Relation" do
    assert_kind_of ActiveRecord::Relation, @root.descendants
  end

  test "leaves have no descendants" do
    assert_empty @level1_3.descendants
  end

  test "performs only one query" do
    assert_queries_count(1) { @root.descendants.count }
  end

  test "it doesn't contain the node" do
    assert_not_includes @root.descendants, @root
  end
end
