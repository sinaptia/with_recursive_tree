require "test_helper"

class SelfAndSiblingsTest < ActiveSupport::TestCase
  test "returns an ActiveRecord::Relation" do
    assert_kind_of ActiveRecord::Relation, @a_node.self_and_siblings
  end

  test "performs only one query" do
    assert_queries_count(1) { @a_node.self_and_siblings.count }
  end

  test "returns the current record and its siblings" do
    assert_equal @a_node.self_and_siblings, [@a_node, @d_node]
  end
end
