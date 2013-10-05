$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "visual_migrate/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "visual_migrate"
  s.version     = VisualMigrate::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of VisualMigrate."
  s.description = "TODO: Description of VisualMigrate."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.0"

  s.add_development_dependency "sqlite3"
end
