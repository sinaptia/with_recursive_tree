require "with_recursive_tree/version"

module WithRecursiveTree
  module ClassMethods
    def with_recursive_tree(primary_key: :id, foreign_key: :parent_id, foreign_key_type: nil, order: nil)
      include InstanceMethods

      scope_condition = foreign_key_type.present? ? -> { where foreign_key_type => self.class.name } : -> { self }

      belongs_to :parent, scope_condition, class_name: name, primary_key: primary_key, foreign_key: foreign_key, inverse_of: :children, optional: true

      has_many :children, -> { scope_condition.call.order(order) }, class_name: name, primary_key: primary_key, foreign_key: foreign_key, inverse_of: :parent

      define_singleton_method(:with_recursive_tree_primary_key) { primary_key }
      define_singleton_method(:with_recursive_tree_foreign_key) { foreign_key }
      define_singleton_method(:with_recursive_tree_foreign_key_type) { foreign_key_type }
      define_singleton_method(:with_recursive_tree_order) { order || primary_key }
      define_singleton_method(:with_recursive_tree_order_column) do
        if with_recursive_tree_order.is_a?(Hash)
          with_recursive_tree_order.keys.first
        else
          with_recursive_tree_order.to_s.split(" ").first
        end
      end

      if foreign_key_type.present?
        before_save do
          if send("#{foreign_key}_changed?")
            if send(foreign_key).present?
              # Only set foreign_key_type to class name if it's not already set to something else
              send("#{foreign_key_type}=", self.class.name) if send(foreign_key_type).blank?
            elsif send(foreign_key).nil?
              # When clearing parent, set type to nil unless explicitly keeping it as model name
              send("#{foreign_key_type}=", nil) unless send(foreign_key_type) == self.class.name
            end
          end
        end
      end

      scope :bfs, -> {
        if defined?(ActiveRecord::ConnectionAdapters::MySQL)
          order(:depth, with_recursive_tree_order)
        else
          order(:depth)
        end
      }
      scope :dfs, -> do
        if defined?(ActiveRecord::ConnectionAdapters::MySQL)
          order(with_recursive_tree_order, :path)
        elsif defined?(ActiveRecord::ConnectionAdapters::PostgreSQL)
          order(:path)
        elsif defined?(ActiveRecord::ConnectionAdapters::SQLite3)
          self
        end
      end
      scope :roots, -> {
        if with_recursive_tree_foreign_key_type.present?
          # Root conditions with foreign_key_type:
          # 1. nil foreign_key AND nil foreign_key_type
          # 2. nil foreign_key AND foreign_key_type matches model name
          # 3. not nil foreign_key AND foreign_key_type different from model name
          where(with_recursive_tree_foreign_key => nil)
            .where(with_recursive_tree_foreign_key_type => [nil, name])
            .or(
              where.not(with_recursive_tree_foreign_key => nil)
                .where.not(with_recursive_tree_foreign_key_type => name)
            )
        else
          where with_recursive_tree_foreign_key => nil
        end
      }
    end
  end

  module InstanceMethods
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
      return self if root?

      if self.class.with_recursive_tree_foreign_key_type.present?
        # For foreign_key_type, find the first ancestor that satisfies root conditions
        self_and_ancestors.find do |node|
          foreign_key_value = node.send(self.class.with_recursive_tree_foreign_key)
          foreign_key_type_value = node.send(self.class.with_recursive_tree_foreign_key_type)

          if foreign_key_value.nil?
            foreign_key_type_value.nil? || foreign_key_type_value == self.class.name
          else
            foreign_key_type_value != self.class.name
          end
        end
      else
        self_and_ancestors.find_by self.class.with_recursive_tree_foreign_key => nil
      end
    end

    def root?
      foreign_key = self.class.with_recursive_tree_foreign_key
      foreign_key_value = send(foreign_key)

      if self.class.with_recursive_tree_foreign_key_type.present?
        foreign_key_type = self.class.with_recursive_tree_foreign_key_type
        foreign_key_type_value = send(foreign_key_type)

        # Root conditions with foreign_key_type:
        # 1. nil foreign_key AND nil foreign_key_type
        # 2. nil foreign_key AND foreign_key_type matches model name
        # 3. not nil foreign_key AND foreign_key_type different from model name
        if foreign_key_value.nil?
          foreign_key_type_value.nil? || foreign_key_type_value == self.class.name
        else
          foreign_key_type_value != self.class.name
        end
      else
        foreign_key_value.nil?
      end
    end

    def self_and_ancestors
      table_name = self.class.table_name
      foreign_key = self.class.with_recursive_tree_foreign_key
      primary_key = self.class.with_recursive_tree_primary_key

      joins_sql = if self.class.with_recursive_tree_foreign_key_type.present?
        <<~SQL
          JOIN tree ON #{table_name}.#{primary_key} = tree.#{foreign_key}
            AND tree.#{self.class.with_recursive_tree_foreign_key_type} = '#{self.class.name}'
        SQL
      else
        <<~SQL
          JOIN tree ON #{table_name}.#{primary_key} = tree.#{foreign_key}
        SQL
      end

      self.class.with_recursive(
        tree: [
          self.class.where(primary_key => send(primary_key)),
          self.class.joins(joins_sql)
        ]
      ).select("*").from("tree AS #{table_name}")
    end

    def self_and_descendants
      table_name = self.class.table_name
      foreign_key = self.class.with_recursive_tree_foreign_key
      primary_key = self.class.with_recursive_tree_primary_key

      anchor_path = if defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
        "ARRAY[#{self.class.with_recursive_tree_order_column}]::text[]"
      elsif defined?(ActiveRecord::ConnectionAdapters::MySQL)
        "CAST(CONCAT('/', #{primary_key}, '/') AS CHAR(512))"
      elsif defined?(ActiveRecord::ConnectionAdapters::SQLite3Adapter)
        "'/' || #{primary_key} || '/'"
      end

      recursive_path = if defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
        "tree.path || #{table_name}.#{self.class.with_recursive_tree_order_column}::text"
      elsif defined?(ActiveRecord::ConnectionAdapters::MySQL)
        "CONCAT(tree.path, #{table_name}.#{primary_key}, '/')"
      elsif defined?(ActiveRecord::ConnectionAdapters::SQLite3)
        "tree.path || #{table_name}.#{primary_key} || '/'"
      end

      joins_sql = if self.class.with_recursive_tree_foreign_key_type.present?
        <<~SQL
          JOIN tree ON #{table_name}.#{foreign_key} = tree.#{primary_key}
            AND #{table_name}.#{self.class.with_recursive_tree_foreign_key_type} = '#{self.class.name}'
        SQL
      else
        <<~SQL
          JOIN tree ON #{table_name}.#{foreign_key} = tree.#{primary_key}
        SQL
      end

      recursive_query = self.class.joins(joins_sql).select("#{table_name}.*, #{recursive_path} AS path, depth + 1 AS depth")

      unless defined?(ActiveRecord::ConnectionAdapters::MySQL)
        recursive_query = recursive_query.order(self.class.with_recursive_tree_order)
      end

      self.class.with_recursive(
        tree: [
          self.class.where(primary_key => send(primary_key)).select("*, #{anchor_path} AS path, 0 AS depth"),
          Arel.sql(recursive_query.to_sql)
        ]
      ).select("*").from("tree AS #{table_name}")
    end

    def self_and_siblings
      root? ? self.class.roots : parent.children
    end

    def siblings
      self_and_siblings.excluding self
    end
  end

  def self.included(mod)
    mod.extend ClassMethods
  end
end

if Gem::Dependency.new("", "< 7.2.0").match?("", ActiveRecord::VERSION::STRING)
  require "with_recursive_tree/backport"
end

ActiveSupport.on_load :active_record do
  include WithRecursiveTree
end
