$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "visual_migrate/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "visual_migrate"
  s.version     = VisualMigrate::VERSION
  s.summary     = "Visual editor for migration files of Ruby on Rails."
  s.description = "Brings easy way to edit migration files of Ruby on Rails."
  s.authors     = ["Jun'ya Shimoda(JironBach)"]
  s.email       = ["jironbach@gmail.com"]
  s.homepage    = "https://github.com/JironBach/visual_migrate"
  s.licenses    = ['MIT', 'GPL-2']

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.0"

  s.add_dependency "ruby_parser"
  s.add_dependency "file-tail"
  s.add_dependency "sourcify"
  s.add_dependency "ruby2ruby"
  s.add_dependency 'jquery-ui-rails'
  s.add_dependency "systemu"
  s.add_dependency "sqlite3"
end
