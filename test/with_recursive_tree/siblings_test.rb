require "test_helper"

class SiblingsTest < ActiveSupport::TestCase
  test "returns an ActiveRecord::Relation" do
    assert_kind_of ActiveRecord::Relation, @level1_1.siblings
  end

  test "performs only one query" do
    assert_queries_count(1) { @level1_1.siblings.count }
  end

  test "returns the current record and its siblings" do
    assert_equal @level1_1.siblings.order(:id), [@level1_2, @level1_3]
  end
end
