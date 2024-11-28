require "test_helper"

class WithRecursiveTreeTest < ActiveSupport::TestCase
  test "it has a version number" do
    assert WithRecursiveTree::VERSION
  end

  test "it creates the parent association" do
    assert_respond_to Node.new, :parent
  end

  test "it creates the children association" do
    assert_respond_to Node.new, :children
  end
end
