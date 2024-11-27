require "test_helper"

class RootTest < ActiveSupport::TestCase
  test "#root returns the root node of the tree even if it's the root node" do
    assert_equal @root, @root.root
  end

  test "#root returns the root node of the tree" do
    assert_equal @root, @level1_1_a_2.root
  end

  test "#root performs only one query" do
    assert_queries_count(1) { @level1_1_a_2.root }
  end

  test "#root? returns true if the node is a root" do
    assert @root.root?
  end

  test "#root? returns false if the node is not a root" do
    assert_not @level1_1_a_2.root?
  end
end
