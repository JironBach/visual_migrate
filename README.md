visual_migrate
#### migrate plugin for [Ruby on Rails]
visual_migrate brings a easy way to edit migration files for Ruby on Rails.

### Install
* Add
```ruby
group :development do
  gem 'visual_migrate', :git => 'git://github.com/JironBach/visual_migrate.git'
  gem 'systemu'
end
```
  to Gemfile.
* If you use MySQL, add `gem "mysql2", "0.3.11"` to Gemfile. Currently version supports only 0.3.11. 
* Add `mount VisualMigrate::Engine => "/visual_migrate" if ENV[RAILS_ENV] != 'production'` to config/routes.rb.
* Do rake to create schema_migrations.
```bash
rake db:migrate
```

### Usage
* Access "http://localhost:3000/visual_migrate/".
* Click "command line" and do "rails generate model test".
* Click "Edit Migration" and select migration file.

### System requirement
* Ruby 2.0.
* RoR 4.0.
* mysql2 gem `0.3.12`.

### attention
* The applicatoins which loading visual_migrate are allow pending migrations also development enviroment.
* Current Version require mysql2 gem version `0.3.12`. Don't run with version 0.3.13.

### In the Future
* mysql2 version 0.3.13 or later.
* Ruby 1.3?
* RoR 3.2?

