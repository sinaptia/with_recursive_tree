require "test_helper"

class XNode < ActiveRecord::Base
  self.table_name = "nodes"

  with_recursive_tree
end

class TNode < ActiveRecord::Base
  self.table_name = "nodes"

  with_recursive_tree order: :created_at
end

class DfsTest < ActiveSupport::TestCase
  def setup
    @a = Node.create name: "A"
    @l = Node.create name: "L", parent: @a
    @m = Node.create name: "M", parent: @l
    @n = Node.create name: "N", parent: @l
    @o = Node.create name: "O", parent: @n
    @p = Node.create name: "P", parent: @n
    @q = Node.create name: "Q", parent: @n
    @r = Node.create name: "R", parent: @n
    @b = Node.create name: "B", parent: @a
    @c = Node.create name: "C", parent: @b
    @d = Node.create name: "D", parent: @c
    @e = Node.create name: "E", parent: @d
    @f = Node.create name: "F", parent: @d
    @g = Node.create name: "G", parent: @d
    @h = Node.create name: "H", parent: @b
    @i = Node.create name: "I", parent: @h
    @j = Node.create name: "J", parent: @i
    @k = Node.create name: "K", parent: @j

    # make sure there are no other text nodes
    TextNode.delete_all

    @ta = TextNode.create name: "A"
    @tl = TextNode.create name: "L", parent: @ta
    @tm = TextNode.create name: "M", parent: @tl
    @tn = TextNode.create name: "N", parent: @tl
    @to = TextNode.create name: "O", parent: @tn
    @tp = TextNode.create name: "P", parent: @tn
    @tq = TextNode.create name: "Q", parent: @tn
    @tr = TextNode.create name: "R", parent: @tn
    @tb = TextNode.create name: "B", parent: @ta
    @tc = TextNode.create name: "C", parent: @tb
    @td = TextNode.create name: "D", parent: @tc
    @te = TextNode.create name: "E", parent: @td
    @tf = TextNode.create name: "F", parent: @td
    @tg = TextNode.create name: "G", parent: @td
    @th = TextNode.create name: "H", parent: @tb
    @ti = TextNode.create name: "I", parent: @th
    @tj = TextNode.create name: "J", parent: @ti
    @tk = TextNode.create name: "K", parent: @tj
  end

  test "returns the correct path" do
    assert_equal ("A".."R").to_a, @a.self_and_descendants.dfs.map(&:name)
  end

  test "without order, it returns the correct path" do
    root = XNode.roots.last

    assert_equal ["A"] + ("L".."R").to_a + ("B".."K").to_a, root.self_and_descendants.dfs.map(&:name)
  end

  test "returns the correct path ordering by timestamp" do
    root = TNode.roots.last

    assert_equal ["A"] + ("L".."R").to_a + ("B".."K").to_a, root.self_and_descendants.dfs.map(&:name)
  end

  test "returns the correct path with custom primary and foreign keys" do
    assert_equal ("A".."R").to_a, @ta.self_and_descendants.dfs.map(&:name)
  end
end
