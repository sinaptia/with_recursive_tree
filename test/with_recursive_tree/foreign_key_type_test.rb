require "test_helper"

class ForeignKeyTypeTest < ActiveSupport::TestCase
  setup do
    # Polymorphic model setup
    @poly_root = PolymorphicNode.create name: "Poly Root"
    @poly_child1 = PolymorphicNode.create name: "Poly Child 1", parent: @poly_root
    @poly_child2 = PolymorphicNode.create name: "Poly Child 2", parent: @poly_root
    @poly_grandchild = PolymorphicNode.create name: "Poly Grandchild", parent: @poly_child1

    # Non-polymorphic model with polymorphic parent reference setup
    @non_poly_root = NonPolymorphicNode.create name: "Non-Poly Root"
    @non_poly_child1 = NonPolymorphicNode.create name: "Non-Poly Child 1", parent: @non_poly_root
    @non_poly_child2 = NonPolymorphicNode.create name: "Non-Poly Child 2", parent: @non_poly_root
    @non_poly_grandchild = NonPolymorphicNode.create name: "Non-Poly Grandchild", parent: @non_poly_child1

    # Cross-model parent (non-polymorphic node with polymorphic parent)
    @cross_node = NonPolymorphicNode.create name: "Cross Node", pool_id: @poly_root.id, pool_type: "PolymorphicNode"

    # Custom keys model setup
    @custom_root = CustomKeyNode.create name: "Custom Root"
    @custom_child1 = CustomKeyNode.create name: "Custom Child 1", pool: @custom_root
    @custom_child2 = CustomKeyNode.create name: "Custom Child 2", pool: @custom_root
    @custom_grandchild = CustomKeyNode.create name: "Custom Grandchild", pool: @custom_child1
  end

  teardown do
    [PolymorphicNode, NonPolymorphicNode, CustomKeyNode].each(&:delete_all)
  end

  # Test polymorphic nodes
  test "polymorphic node root detection" do
    assert @poly_root.root?
    assert_not @poly_child1.root?
    assert_not @poly_grandchild.root?
  end

  test "polymorphic node roots scope" do
    roots = PolymorphicNode.roots
    assert_includes roots, @poly_root
    assert_not_includes roots, @poly_child1
    assert_not_includes roots, @poly_grandchild
  end

  test "polymorphic node root method" do
    assert_equal @poly_root, @poly_child1.root
    assert_equal @poly_root, @poly_grandchild.root
    assert_equal @poly_root, @poly_root.root
  end

  test "polymorphic node ancestors" do
    assert_equal [@poly_child1, @poly_root], @poly_grandchild.ancestors
    assert_equal [@poly_root], @poly_child1.ancestors
    assert_equal [], @poly_root.ancestors
  end

  test "polymorphic node descendants" do
    expected_descendants = [@poly_child1, @poly_child2, @poly_grandchild]
    assert_equal expected_descendants.sort_by(&:name), @poly_root.descendants.sort_by(&:name)
    assert_equal [@poly_grandchild], @poly_child1.descendants
    assert_equal [], @poly_grandchild.descendants
  end

  # Test non-polymorphic nodes with polymorphic parent reference
  test "non-polymorphic node root detection" do
    assert @non_poly_root.root?
    assert_not @non_poly_child1.root?
    assert_not @non_poly_grandchild.root?

    # Cross-model node should be root because it has different parent type
    assert @cross_node.root?
  end

  test "non-polymorphic node roots scope" do
    roots = NonPolymorphicNode.roots
    assert_includes roots, @non_poly_root
    assert_includes roots, @cross_node # Different parent type makes it root
    assert_not_includes roots, @non_poly_child1
    assert_not_includes roots, @non_poly_grandchild
  end

  test "non-polymorphic node root method" do
    assert_equal @non_poly_root, @non_poly_child1.root
    assert_equal @non_poly_root, @non_poly_grandchild.root
    assert_equal @non_poly_root, @non_poly_root.root
    assert_equal @cross_node, @cross_node.root # Cross node is its own root
  end

  test "non-polymorphic node with cross-model parent" do
    assert @cross_node.pool_id.present?
    assert_equal "PolymorphicNode", @cross_node.pool_type
    assert @cross_node.root? # Should be root because parent type differs from model name
  end

  # Test custom keys (pool_id/pool_type)
  test "custom keys node root detection" do
    assert @custom_root.root?
    assert_not @custom_child1.root?
    assert_not @custom_grandchild.root?
  end

  test "custom keys node roots scope" do
    roots = CustomKeyNode.roots
    assert_includes roots, @custom_root
    assert_not_includes roots, @custom_child1
    assert_not_includes roots, @custom_grandchild
  end

  test "custom keys node root method" do
    assert_equal @custom_root, @custom_child1.root
    assert_equal @custom_root, @custom_grandchild.root
    assert_equal @custom_root, @custom_root.root
  end

  test "custom keys node ancestors" do
    assert_equal [@custom_child1, @custom_root], @custom_grandchild.ancestors
    assert_equal [@custom_root], @custom_child1.ancestors
    assert_equal [], @custom_root.ancestors
  end

  test "custom keys node descendants" do
    expected_descendants = [@custom_child1, @custom_child2, @custom_grandchild]
    assert_equal expected_descendants.sort_by(&:name), @custom_root.descendants.sort_by(&:name)
    assert_equal [@custom_grandchild], @custom_child1.descendants
    assert_equal [], @custom_grandchild.descendants
  end

  # Test edge cases
  test "node with nil foreign_key and nil foreign_key_type should be root" do
    node = PolymorphicNode.create name: "Orphan", parent_id: nil, parent_type: nil
    assert node.root?
    assert_includes PolymorphicNode.roots, node
  end

  test "node with nil foreign_key and matching foreign_key_type should be root" do
    node = PolymorphicNode.create name: "Typed Root", parent_id: nil, parent_type: "PolymorphicNode"
    assert node.root?
    assert_includes PolymorphicNode.roots, node
  end

  test "node with foreign_key and different foreign_key_type should be root" do
    node = PolymorphicNode.create name: "Cross Root", parent_id: 999, parent_type: "OtherModel"
    assert node.root?
    assert_includes PolymorphicNode.roots, node
  end

  test "node with foreign_key and matching foreign_key_type should not be root" do
    # This is a normal child node
    assert_not @poly_child1.root?
    assert @poly_child1.parent_id.present?
    assert_equal "PolymorphicNode", @poly_child1.parent_type
  end
end
