require 'active_record/migration'

module VisualMigrate
  class ActiveRecord::Migrator#:nodoc:
    class << self
      #process_method = instance_method(:needs_migration?)
      #undef :needs_migration?

      #define_method(needs_migration?) do |connection|
      def needs_migration?(connection)
        false#current_version(connection) < last_version
      end
    end
  end

end
