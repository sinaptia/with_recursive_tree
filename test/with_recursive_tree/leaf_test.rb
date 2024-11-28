require "test_helper"

class LeafTest < ActiveSupport::TestCase
  test "performs only one query" do
    assert_queries_count(1) { @root.leaf? }
  end

  test "a node with children is not a leaf" do
    assert_not @root.leaf?
  end

  test "a node with no childlren is a leaf" do
    assert @a_node.leaf?
  end
end
