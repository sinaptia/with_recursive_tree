require "test_helper"

class LevelTest < ActiveSupport::TestCase
  test "performs only one query" do
    assert_queries_count(1) { @root.level }
  end

  test "the root node is level 0" do
    assert_equal 0, @root.level
  end

  test "the level is equal to the number of ancestors" do
    assert_equal 1, @level1_1.level
  end
end
