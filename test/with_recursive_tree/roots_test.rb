require "test_helper"

class RootsTest < ActiveSupport::TestCase
  test "returns an association" do
    assert_kind_of ActiveRecord::Relation, Node.roots
  end

  test "the returned items have no parent" do
    Node.create name: "another root"

    assert_equal 2, Node.roots.count

    assert_equal true, Node.roots.all? { _1.parent.blank? }
  end

  test "performs one query" do
    assert_queries_count(1) { Node.roots.count }
  end
end
