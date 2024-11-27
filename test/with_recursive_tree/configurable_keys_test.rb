require "test_helper"

class ConfigurableKeysTest < ActiveSupport::TestCase
  test "::roots works with custom primary and foreign keys" do
    assert_includes Thing.roots, @thing_root
  end

  test "#ancestors works with custom primary and foreign keys" do
    assert_equal @thing_level1_1_a.ancestors.order(:id), [@thing_level1_1, @thing_root].sort_by(&:id)
  end

  test "#descendants works with custom primary and foreign keys" do
    assert_equal @thing_root.descendants.order(:id), [@thing_level1_1, @thing_level1_1_a, @thing_level1_1_a_1, @thing_level1_1_b, @thing_level1_2, @thing_level1_2_a, @thing_level1_2_b].sort_by(&:id)
  end

  test "#leaf? works with custom primary and foreign keys" do
    assert @thing_level1_2_a.leaf?
  end

  test "#level works with custom primary and foreign keys" do
    assert_equal 2, @level1_1_a.level
  end

  test "#root? works with custom primary and foreign keys" do
    assert @thing_root.root?
  end

  test "#root works with custom primary and foreign keys" do
    assert_equal @thing_root, @thing_level1_1.root
  end

  test "#self_and_ancestors works with custom primary and foreign keys" do
    assert_equal @thing_level1_1_a.self_and_ancestors.order(:id), [@thing_level1_1_a, @thing_level1_1, @thing_root].sort_by(&:id)
  end

  test "#self_and_descendants works with custom primary and foreign keys" do
    assert_equal @thing_root.self_and_descendants.order(:id), [@thing_root, @thing_level1_1, @thing_level1_1_a, @thing_level1_1_a_1, @thing_level1_1_b, @thing_level1_2, @thing_level1_2_a, @thing_level1_2_b].sort_by(&:id)
  end

  test "#self_and_siblings works with custom primary and foreign keys" do
    assert_equal @thing_level1_1.self_and_siblings.order(:id), [@thing_level1_1, @thing_level1_2].sort_by(&:id)
  end

  test "#siblings works with custom primary and foreign keys" do
    assert_equal @thing_level1_1.siblings.order(:id), [@thing_level1_2].sort_by(&:id)
  end
end
