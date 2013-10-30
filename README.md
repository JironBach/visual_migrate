#visual_migrate
## migrate plugin for Ruby on Rails
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
* If you use MySQL, add `gem "mysql2", "0.3.12"` to Gemfile. Currentlly version supports under 0.3.12. 
* Add `mount VisualMigrate::Engine => "/visual_migrate" if ENV[RAILS_ENV] != 'production'` to config/routes.rb.
* If schema_migrations is not exists in database, then do rake to create schema_migrations.
```
rake db:migrate
```

### Usage
* Run webrick and access `http://localhost:3000/visual_migrate/`.
* Click "command line" tab and do `rails generate model ...` or `rails generate migration ...`.
* Click and edit new migration file. When you finished to edit, then save.
* Click "command line" tab and do `rake db:migrate`.
* Migrated files are not available to edit. If you need to re-edit, then do `rake db:rollback` or `rake db:migrate:down VERSION=...`.

### System requirement
* Ruby 2.0.
* RoR 4.0.
* mysql2 gem `'0.3.12'`.

### attention
* The applicatoins which loading visual_migrate are allow pending migrations in development enviroment.
* Current Version require mysql2 gem version `0.3.12`. Don't run with version 0.3.13 or later.
* Current Version clear session when run command. So login session will maybe cancelled.

### In the Future
* Select session variables to clear when run command.
* mysql2 version 0.3.13 or later.
* Ruby 1.3?
* RoR 3.2?

