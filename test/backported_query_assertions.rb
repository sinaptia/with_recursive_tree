module ActiveRecord
  module Assertions
    module QueryAssertions
      def assert_queries_count(count = nil, include_schema: false, &block)
        ActiveRecord::Base.connection.materialize_transactions

        counter = SQLCounter.new
        ActiveSupport::Notifications.subscribed(counter.method(:call), "sql.active_record") do
          result = block.call
          queries = include_schema ? counter.log_all : counter.log
          if count
            assert_equal count, queries.size, "#{queries.size} instead of #{count} queries were executed. Queries: #{queries.join("\n\n")}"
          else
            assert_operator queries.size, :>=, 1, "1 or more queries expected, but none were executed.#{queries.empty? ? "" : "\nQueries:\n#{queries.join("\n")}"}"
          end
          result
        end
      end

      class SQLCounter # :nodoc:
        attr_reader :log_full, :log_all

        def initialize
          @log_full = []
          @log_all = []
        end

        def log
          @log_full.map(&:first)
        end

        def call(*, payload)
          return if payload[:cached]

          sql = payload[:sql]
          @log_all << sql

          unless payload[:name] == "SCHEMA"
            bound_values = (payload[:binds] || []).map do |value|
              value = value.value_for_database if value.respond_to?(:value_for_database)
              value
            end

            @log_full << [sql, bound_values]
          end
        end
      end
    end
  end
end
