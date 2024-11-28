if ARGV.size != 2
  puts "Usage: ruby benchmarks/benchmark.rb <levels> <siblings>"
end

levels, siblings = Integer(ARGV[0]), Integer(ARGV[1])

%w[acts_as_tree ancestry closure_tree with_recursive_tree].each do |lib|
  puts "Running benchmarks for #{lib}..."

  system "ruby ./benchmarks/#{lib}_benchmark.rb #{levels} #{siblings}"
end
