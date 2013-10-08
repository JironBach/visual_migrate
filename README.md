visual_migrate
<<<<<<< HEAD
=======
=======
>>>>>>> aee82b7b21f151dc812a46f3bdf6215a5f1f1c78
#### migrate plugin for [Ruby on Rails]
visual_migrate brings a easy way to edit migration files for Ruby on Rails.

### Install
* Add `gem 'visual_migrate', :git => 'git://github.com/JironBach/visual_migrate.git'` and `gem 'systemu'` to Gemfile.
* If you use MySQL, add `gem "mysql2", "0.3.11"` to Gemfile. Currently version supports only 0.3.11. 
* Add `mount VisualMigrate::Engine => "/visual_migrate"` to config/routes.rb.
*
<<<<<<< HEAD
* ```bash
=======
```bash
>>>>>>> aee82b7b21f151dc812a46f3bdf6215a5f1f1c78
rake db:migrate
```
  to create schema_migrations.

### Usage
* Access "http://localhost:3000/visual_migrate/".
* Click "command line" and do "rails generate mod.el test"
* Click "Edit Migration" and select migration file.

### System requirement
* Ruby 2.0 or later.
* RoR 4.0 or later.
<<<<<<< HEAD

### System require
* Ruby 2.0 or later
* RoR 4.0 or later
=======
>>>>>>> aee82b7b21f151dc812a46f3bdf6215a5f1f1c78

### In the Future
* Ruby 1.3?
* RoR 3.2?

