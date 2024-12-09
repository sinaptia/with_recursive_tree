require "test_helper"

class BfsTest < ActiveSupport::TestCase
  def setup
    @a = Node.create name: "A"
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
    @l = Node.create name: "L", parent: @a
    @m = Node.create name: "M", parent: @l
    @n = Node.create name: "N", parent: @l
    @o = Node.create name: "O", parent: @n
    @p = Node.create name: "P", parent: @n
    @q = Node.create name: "Q", parent: @n
    @r = Node.create name: "R", parent: @n
  end

  test "returns the correct path" do
    assert_equal %w[A B L C H M N D I O P Q R E F G J K], @a.self_and_descendants.bfs.map(&:name)
  end
end
