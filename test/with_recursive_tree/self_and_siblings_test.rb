require "test_helper"

class SelfAndSiblingsTest < ActiveSupport::TestCase
  test "returns an ActiveRecord::Relation" do
    assert_kind_of ActiveRecord::Relation, @level1_1.self_and_siblings
  end

  test "performs only one query" do
    assert_queries_count(1) { @level1_1.self_and_siblings.count }
  end

  test "returns the current record and its siblings" do
    assert_equal @level1_1.self_and_siblings.order(:id), [@level1_1, @level1_2, @level1_3].sort_by(&:id)
  end
end
