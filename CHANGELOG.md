# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.0] - 2025-09-23

### Added

- Add foreign_key_type for polymorphic trees (@texpert, @patriciomacadden)

## [0.3.0] - 2025-06-24

### Changed

- Prevent instance methods and scopes from being added to all ActiveRecord classes. Only add them if `with_recursive_tree` is called in the class definition.

## [0.2.0] - 2024-12-27

### Added

- Support for Rails 6.0 and above
- CI matrix with Ruby 3.1 to 3.4 and Rails 6.0 to 8.0
- Support for Ruby 3.0

## [0.1.1] - 2024-12-10

### Added

- Better support for MySQL and Postgres
- Add tests for `::dfs`
