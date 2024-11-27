require "active_support/concern"

require "with_recursive_tree/version"

module WithRecursiveTree
  extend ActiveSupport::Concern

  class_methods do
    def with_recursive_tree(primary_key: :id, foreign_key: :parent_id)
      belongs_to :parent, class_name: name, primary_key: primary_key, foreign_key: foreign_key, inverse_of: :children, optional: true

      has_many :children, class_name: name, primary_key: primary_key, foreign_key: foreign_key, inverse_of: :parent

      define_singleton_method(:with_recursive_tree_primary_key) { primary_key }
      define_singleton_method(:with_recursive_tree_foreign_key) { foreign_key }
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

  def level
    ancestors.count
  end

  def root
    self_and_ancestors.find_by self.class.with_recursive_tree_foreign_key => nil
  end

  def root?
    parent.blank?
  end

  def self_and_ancestors
    self.class.where self.class.with_recursive_tree_primary_key => self.class.with_recursive(
      search_tree: [
        self.class.where(self.class.with_recursive_tree_primary_key => send(self.class.with_recursive_tree_primary_key)),
        self.class.joins("JOIN search_tree ON #{self.class.table_name}.#{self.class.with_recursive_tree_primary_key} = search_tree.#{self.class.with_recursive_tree_foreign_key}")
      ]
    ).select(self.class.with_recursive_tree_primary_key).from("search_tree")
  end

  def self_and_descendants
    self.class.where self.class.with_recursive_tree_primary_key => self.class.with_recursive(
      search_tree: [
        self.class.where(self.class.with_recursive_tree_primary_key => send(self.class.with_recursive_tree_primary_key)),
        self.class.joins("JOIN search_tree ON #{self.class.table_name}.#{self.class.with_recursive_tree_foreign_key} = search_tree.#{self.class.with_recursive_tree_primary_key}")
      ]
    ).select(self.class.with_recursive_tree_primary_key).from("search_tree")
  end

  def self_and_siblings
    parent.present? ? parent.children : self.class.roots
  end

  def siblings
    self_and_siblings.excluding self
  end
end

ActiveSupport.on_load :active_record do
  include WithRecursiveTree
end
