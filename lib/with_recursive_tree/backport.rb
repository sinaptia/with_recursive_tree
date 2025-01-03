module WithRecursiveTree
  def ancestors
    self_and_ancestors.where.not self.class.with_recursive_tree_primary_key => send(self.class.with_recursive_tree_primary_key)
  end

  def descendants
    self_and_descendants.where.not self.class.with_recursive_tree_primary_key => send(self.class.with_recursive_tree_primary_key)
  end

  def self_and_ancestors
    sql = <<-SQL
    WITH RECURSIVE tree AS (
      #{self.class.where(self.class.with_recursive_tree_primary_key => send(self.class.with_recursive_tree_primary_key)).to_sql}
      UNION ALL
      #{self.class.joins("JOIN tree ON #{self.class.table_name}.#{self.class.with_recursive_tree_primary_key} = tree.#{self.class.with_recursive_tree_foreign_key}").to_sql}
      ) SELECT * FROM tree
    SQL

    self.class.select("*").from("(#{sql}) AS #{self.class.table_name}")
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

    # order by is only available in SQLIte for rails versions older than 7.2
    if defined?(ActiveRecord::ConnectionAdapters::SQLite3)
      recursive_query = recursive_query.order(self.class.with_recursive_tree_order)
    end

    sql = <<-SQL
      WITH RECURSIVE tree AS (
        #{self.class.where(self.class.with_recursive_tree_primary_key => send(self.class.with_recursive_tree_primary_key)).select("*, #{anchor_path} AS path, 0 AS depth").to_sql}
        UNION ALL
        #{Arel.sql(recursive_query.to_sql)}
      ) SELECT * FROM tree
    SQL

    self.class.select("*").from("(#{sql}) AS #{self.class.table_name}")
  end

  def siblings
    self_and_siblings.where.not self.class.with_recursive_tree_primary_key => send(self.class.with_recursive_tree_primary_key)
  end
end
