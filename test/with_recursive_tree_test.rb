require "test_helper"

class WithRecursiveTreeTest < ActiveSupport::TestCase
  test "it has a version number" do
    assert WithRecursiveTree::VERSION
  end

  test "adds with_recursive_tree class methods and scopes if with_recurive_tree has been called in the class definition" do
    assert_respond_to Node, :bfs
    assert_respond_to Node, :dfs
    assert_respond_to Node, :roots
    assert_respond_to Node, :with_recursive_tree_foreign_key
    assert_respond_to Node, :with_recursive_tree_order
    assert_respond_to Node, :with_recursive_tree_order_column
    assert_respond_to Node, :with_recursive_tree_primary_key
  end

  test "adds with_recursive_tree instance methods if with_recurive_tree has been called in the class definition" do
    instance = Node.new

    WithRecursiveTree::InstanceMethods.instance_methods.each do |method|
      assert_respond_to instance, method
    end
  end

  test "doesn't add with_recursive_tree class methods and scopes if with_recurive_tree hasn't been called in the class definition" do
    assert_not_respond_to Person, :bfs
    assert_not_respond_to Person, :dfs
    assert_not_respond_to Person, :roots
    assert_not_respond_to Person, :with_recursive_tree_foreign_key
    assert_not_respond_to Person, :with_recursive_tree_order
    assert_not_respond_to Person, :with_recursive_tree_order_column
    assert_not_respond_to Person, :with_recursive_tree_primary_key
  end

  test "doesn't add with_recursive_tree instance methods if with_recurive_tree hasn't been called in the class definition" do
    instance = Person.new

    WithRecursiveTree::InstanceMethods.instance_methods.each do |method|
      assert_not_respond_to instance, method
    end
  end
end
