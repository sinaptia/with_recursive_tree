require "test_helper"

class DepthTest < ActiveSupport::TestCase
  test "performs only one query if the node has no depth" do
    assert_queries_count(1) { @root.depth }
  end

  test "the depth is calculated automatically when calling #self_and_descendants and performs no queries" do
    node = @root.self_and_descendants[3]

    assert_queries_count(0) { node.depth }
  end

  test "the depth is calculated for the subtree when calling #self_and_descendants" do
    node = @a_node.self_and_descendants.first

    assert_equal 0, node.depth
  end

  test "the depth is calculated for the subtree when calling #descendants" do
    node = @d_node.descendants.first

    assert_equal 1, node.depth
  end

  test "the root node is depth 0" do
    assert_equal 0, @root.depth
  end

  test "the depth is equal to the number of ancestors" do
    assert_equal 2, @a_node.depth
  end
end
