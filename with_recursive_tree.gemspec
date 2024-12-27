require_relative "lib/with_recursive_tree/version"

Gem::Specification.new do |spec|
  spec.name = "with_recursive_tree"
  spec.version = WithRecursiveTree::VERSION
  spec.authors = ["Patricio Mac Adden"]
  spec.email = ["patriciomacadden@gmail.com"]
  spec.homepage = "https://github.com/sinaptia/with_recursive_tree"
  spec.summary = "Tree structures for ActiveRecord"
  spec.description = "Tree structures for ActiveRecord"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.required_ruby_version = ">= 3.1.0"

  spec.add_dependency "activerecord", ">= 6.0"
  spec.add_dependency "activesupport", ">= 6.0"
  spec.add_dependency "railties", ">= 6.0"
end
