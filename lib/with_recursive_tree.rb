require "active_support/concern"

require "with_recursive_tree/version"

module WithRecursiveTree
  extend ActiveSupport::Concern

  included do
    scope :bfs, -> {
      if defined?(ActiveRecord::ConnectionAdapters::MySQL)
        order :depth, with_recursive_tree_order
      else
        order :depth
      end
    }
    scope :dfs, -> do
      if defined?(ActiveRecord::ConnectionAdapters::MySQL)
        order with_recursive_tree_order, :path
      elsif defined?(ActiveRecord::ConnectionAdapters::PostgreSQL)
        order :path
      elsif defined?(ActiveRecord::ConnectionAdapters::SQLite3)
        self
      end
    end
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

    def with_recursive_tree_order_column
      if with_recursive_tree_order.is_a?(Hash)
        with_recursive_tree_order.keys.first
      else
        with_recursive_tree_order.to_s.split(" ").first
      end
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
    self.class.with_recursive(
      tree: [
        self.class.where(self.class.with_recursive_tree_primary_key => send(self.class.with_recursive_tree_primary_key)),
        self.class.joins("JOIN tree ON #{self.class.table_name}.#{self.class.with_recursive_tree_primary_key} = tree.#{self.class.with_recursive_tree_foreign_key}")
      ]
    ).select("*").from("tree AS #{self.class.table_name}")
  end

  def self_and_descendants
    anchor_path = if defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
      "ARRAY[#{self.class.with_recursive_tree_order_column}]::text[]"
    elsif defined?(ActiveRecord::ConnectionAdapters::MySQL)
      "CAST(CONCAT('/', #{self.class.with_recursive_tree_primary_key}, '/') AS CHAR(512))"
    elsif defined?(ActiveRecord::ConnectionAdapters::SQLite3Adapter)
      "'/' || #{self.class.with_recursive_tree_primary_key} || '/'"
    end

    recursive_path = if defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
      "tree.path || #{self.class.table_name}.#{self.class.with_recursive_tree_order_column}::text"
    elsif defined?(ActiveRecord::ConnectionAdapters::MySQL)
      "CONCAT(tree.path, #{self.class.table_name}.#{self.class.with_recursive_tree_primary_key}, '/')"
    elsif defined?(ActiveRecord::ConnectionAdapters::SQLite3)
      "tree.path || #{self.class.table_name}.#{self.class.with_recursive_tree_primary_key} || '/'"
    end

    recursive_query = self.class.joins("JOIN tree ON #{self.class.table_name}.#{self.class.with_recursive_tree_foreign_key} = tree.#{self.class.with_recursive_tree_primary_key}").select("#{self.class.table_name}.*, #{recursive_path} AS path, depth + 1 AS depth")

    unless defined?(ActiveRecord::ConnectionAdapters::MySQL)
      recursive_query = recursive_query.order(self.class.with_recursive_tree_order)
    end

    self.class.with_recursive(
      tree: [
        self.class.where(self.class.with_recursive_tree_primary_key => send(self.class.with_recursive_tree_primary_key)).select("*, #{anchor_path} AS path, 0 AS depth"),
        Arel.sql(recursive_query.to_sql)
      ]
    ).select("*").from("tree AS #{self.class.table_name}")
  end

  def self_and_siblings
    root? ? self.class.roots : parent.children
  end

  def siblings
    self_and_siblings.excluding self
  end
end

if Gem::Dependency.new("", "< 7.2.0").match?("", ActiveRecord::VERSION::STRING)
  require "with_recursive_tree/backport"
end

ActiveSupport.on_load :active_record do
  include WithRecursiveTree
end
