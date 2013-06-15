# -*- coding: utf-8 -*-

require_dependency "visual_migrate/application_controller"

require 'pathname'
require 'visual_migrate_ripper'
require 'migrate_defs'

module VisualMigrate
  class IndexController < ApplicationController
    
    def show_migrations
      @section_category = :migrations
      
      d = Pathname(Rails.root.to_s + '/db/migrate/')
      files = d.children
      @migration_files = []
      files.each do |f|
        @migration_files << f if f.extname == '.rb'
      end
    end
    
    def show_tables
      @section_category = :tables
      
      @tables = ActiveRecord::Base.connection.tables
    end
    
    def index
      edit_migrations
    end
    
    def edit_migrations
      show_migrations
      
      migration_filename = Rails.root.to_s + '/db/migrate/' + params[:id] + '.rb'
      if !params[:id].nil?
        migration_content = ''
        open(migration_filename, 'r') do |f|
          migration_content = f.read
        end

        @migration_content = Ripper.lex(migration_content)
        vm_ripper = VisualMigrateRipper.new migration_content
        vm_ripper.parse
        @context = vm_ripper.get_str
        @vm_ripper = vm_ripper

        #parsed_migration = RubyParser.new.parse(@context)
        #@context = Ruby2Ruby.new.process(parsed_migration)
        #open('/tmp/vm.txt', 'w') do |f|
        #  f.write(@context)
        #end
      end
      
      render :edit_migrations
    end
    
    def edit_tables
      show_tables
      
      render :edit_tables
    end
    
    def add_migration
      edit_tables
    end
    
    def create_model
      show_tables

      render :create_model
    end
    
    def do_create_model
      create_model
    end
  end
end
