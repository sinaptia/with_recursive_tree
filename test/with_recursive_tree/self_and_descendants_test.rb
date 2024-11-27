require "test_helper"

class SelfAndDescedantsTest < ActiveSupport::TestCase
  test "performs only one query" do
    assert_queries_count(1) { @root.self_and_descendants.count }
  end

  test "returns an ActiveRecord::Relation" do
    assert_kind_of ActiveRecord::Relation, @root.self_and_descendants
  end

  test "the collection returns self and the descendants" do
    assert_equal @level1_1.self_and_descendants.order(:id), [@level1_1, @level1_1_a, @level1_1_b, @level1_1_c, @level1_1_a_1, @level1_1_a_2, @level1_1_b_1].sort_by(&:id)
  end
end
