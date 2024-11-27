# WithRecursiveTree

Tree structures for ActiveRecord using CTE (Common Table Expressions). This allows to traverse the whole tree with just one query.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "with_recursive_tree"
```

And then execute:

```bash
$ bundle
```

## Usage

Add `with_recursive_tree` to your model:

```ruby
class Category < ApplicationRecord
  with_recursive_tree
end
```

WithRecursiveTree assumes you have a `parent_id` column in your table. If you use another name for this column, pass it to `with_recursive_tree`:

```ruby
class Category < ApplicationRecord
  with_recursive_tree foreign_key: :parent_category_id
end
```

You can also specify the name of the column used as the primary key:

```ruby
class Category < ApplicationRecord
 with_recursive_tree foreign_key: :parent_category_id, primary_key: :category_id
end
```

### Class methods

WithRecursiveTree will define a `parent` association and a `children` association. It also adds the `#roots` method, which will return all nodes without parent.

### Instance methods

| Method | Description |
|--------|-------------|
| `#ancestors` | Returns all ancestors of the node. |
| `#descendants` | Returns all descendants of the node (subtree). |
| `#leaf?` | Returns whether the node is a leaf (has no children). |
| `#level` | Returns the level of the current node |
| `#root` | Returns the root node of the current node's tree. |
| `#root?` | Returns whether the node is a root (has no parent). |
| `#self_and_ancestors` | Returns the node and all its ancestors. |
| `#self_and_descendants` | Returns the node and all its descendants (subtree). |
| `#self_and_siblings` | Returns the current node and all its siblings. |
| `#siblings` | Returns the current node's siblings. |

## Contributing

For the repo, add your feature, create a PR.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
