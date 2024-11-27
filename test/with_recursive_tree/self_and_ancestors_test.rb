require "test_helper"

class SelfAndAncestorsTest < ActiveSupport::TestCase
  test "performs only one query" do
    assert_queries_count(1) { @level1_3.self_and_ancestors.count }
  end

  test "returns an ActiveRecord::Relation" do
    assert_kind_of ActiveRecord::Relation, @level1_3.self_and_ancestors
  end

  test "the collection returns self and the ancestors" do
    assert_equal @level1_1_a_1.self_and_ancestors.order(:id), [@root, @level1_1, @level1_1_a, @level1_1_a_1].sort_by(&:id)
  end
end
