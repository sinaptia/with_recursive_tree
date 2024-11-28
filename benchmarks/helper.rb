require "bundler/setup"

require "active_record"
require "active_support"
require "benchmark"
require "debug"

def create_tree(parent = nil, level = 0, max_levels = 3, siblings = 2)
  return if level > max_levels

  siblings.times do
    node = Node.create parent: parent

    create_tree node, level + 1, max_levels
  end
end

def silence
  stdout = $stdout
  $stdout = StringIO.new

  yield
ensure
  $stdout = stdout
end

# ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
begin
  FileUtils.rm "benchmark.sqlite3"
rescue
  # do nothing
end
ActiveRecord::Base.establish_connection adapter: "sqlite3", database: "benchmark.sqlite3"
