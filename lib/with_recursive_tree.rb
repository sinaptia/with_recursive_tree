require "active_support/concern"

require "with_recursive_tree/version"

module WithRecursiveTree
  extend ActiveSupport::Concern

  included do
    scope :bfs, -> { order :depth }
    scope :dfs, -> { self }
  end

  class_methods do
    def with_recursive_tree(primary_key: :id, foreign_key: :parent_id, order: nil)
      belongs_to :parent, class_name: name, primary_key: primary_key, foreign_key: foreign_key, inverse_of: :children, optional: true

      has_many :children, -> { order order }, class_name: name, primary_key: primary_key, foreign_key: foreign_key, inverse_of: :parent

      define_singleton_method(:with_recursive_tree_primary_key) { primary_key }
      define_singleton_method(:with_recursive_tree_foreign_key) { foreign_key }
      define_singleton_method(:with_recursive_tree_order) { order || primary_key }
    end

    def roots
      where with_recursive_tree_foreign_key => nil
    end
  end

  def ancestors
    self_and_ancestors.excluding self
  end

  def descendants
    self_and_descendants.excluding self
  end

  def leaf?
    children.none?
  end

  def depth
    attributes["depth"] || ancestors.count
  end
  alias_method :level, :depth

  def root
    self_and_ancestors.find_by self.class.with_recursive_tree_foreign_key => nil
  end

  def root?
    parent.blank?
  end

  def self_and_ancestors
    self.class.with(search_tree: self.class.with_recursive(
      search_tree: [
        self.class.where(self.class.with_recursive_tree_primary_key => send(self.class.with_recursive_tree_primary_key)),
        self.class.joins("JOIN search_tree ON #{self.class.table_name}.#{self.class.with_recursive_tree_primary_key} = search_tree.#{self.class.with_recursive_tree_foreign_key}")
      ]
    ).select("*").from("search_tree")).from("search_tree AS #{self.class.table_name}")
  end

  def self_and_descendants
    self.class.with(search_tree: self.class.with_recursive(
      search_tree: [
        self.class.where(self.class.with_recursive_tree_primary_key => send(self.class.with_recursive_tree_primary_key)).select("*, '/' || #{self.class.with_recursive_tree_primary_key} || '/' AS path, 0 AS depth"),
        Arel.sql(self.class.joins("JOIN search_tree ON #{self.class.table_name}.#{self.class.with_recursive_tree_foreign_key} = search_tree.#{self.class.with_recursive_tree_primary_key}").select("#{self.class.table_name}.*, search_tree.path || #{self.class.table_name}.#{self.class.with_recursive_tree_primary_key} || '/' AS path, depth + 1 AS depth").order(self.class.with_recursive_tree_order).to_sql)
      ]
    ).select("*").from("search_tree")).from("search_tree AS #{self.class.table_name}")
  end

  def self_and_siblings
    root? ? self.class.roots : parent.children
  end

  def siblings
    self_and_siblings.excluding self
  end
end

ActiveSupport.on_load :active_record do
  include WithRecursiveTree
end
