require "test_helper"

class ConfigurableKeysTest < ActiveSupport::TestCase
  test "::roots works with custom primary and foreign keys" do
    assert_includes TextNode.roots, @troot
  end

  test "#ancestors works with custom primary and foreign keys" do
    assert_equal @a_tnode.ancestors, [@b_tnode, @troot]
  end

  test "#descendants works with custom primary and foreign keys" do
    assert_equal @d_tnode.descendants, [@c_tnode, @e_tnode]
  end

  test "#leaf? works with custom primary and foreign keys" do
    assert @a_tnode.leaf?
  end

  test "#depth works with custom primary and foreign keys" do
    assert_equal 2, @a_tnode.depth
  end

  test "#root? works with custom primary and foreign keys" do
    assert @troot.root?
  end

  test "#root works with custom primary and foreign keys" do
    assert_equal @troot, @a_tnode.root
  end

  test "#self_and_ancestors works with custom primary and foreign keys" do
    assert_equal @a_tnode.self_and_ancestors, [@a_tnode, @b_tnode, @troot]
  end

  test "#self_and_descendants works with custom primary and foreign keys" do
    assert_equal @d_tnode.self_and_descendants, [@d_tnode, @c_tnode, @e_tnode]
  end

  test "#self_and_siblings works with custom primary and foreign keys" do
    assert_equal @b_tnode.self_and_siblings, [@b_tnode, @g_tnode]
  end

  test "#siblings works with custom primary and foreign keys" do
    assert_equal @b_tnode.siblings, [@g_tnode]
  end
end
