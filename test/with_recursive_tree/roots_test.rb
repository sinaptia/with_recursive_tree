require "test_helper"

class RootsTest < ActiveSupport::TestCase
  test "returns an association" do
    assert_kind_of ActiveRecord::Relation, Category.roots
  end

  test "the returned items have no parent" do
    assert_equal 2, Category.roots.count

    assert_equal true, Category.roots.all? { _1.parent.blank? }
  end

  test "performs one query" do
    assert_queries_count(1) { Category.roots.count }
  end
end
