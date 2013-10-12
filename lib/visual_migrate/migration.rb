require 'active_record/migration'

module VisualMigrate
  class ActiveRecord::Migrator#:nodoc:
    class << self
      process_method = instance_method(:needs_migration?)
      undef :needs_migration?

      define_method :needs_migration? do
        false#current_version < last_version
      end

    end
  end
end
