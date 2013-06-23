# -*- coding: utf-8 -*-

require_dependency "visual_migrate/application_controller"

require 'pathname'
require 'visual_migrate_ripper'
require 'migration_defs'

module VisualMigrate
  include ApplicationHelper

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
      edit_migration
    end
    
    def edit_migration
      show_migrations
      
      if !params[:id].nil?
        migration_filename = Rails.root.to_s + '/db/migrate/' + params[:id] + '.rb'
        migration_content = ''
        open(migration_filename, 'r') do |f|
          migration_content = f.read
        end

        @mi_lex = Ripper.lex(migration_content)
        vm_ripper = VisualMigrateRipper.new migration_content
        vm_ripper.parse
        #@context = vm_ripper.get_str
        @vm_ripper = vm_ripper
      end
      
      @edit_mode = 'edit_migration'
      render :edit_migration
    end
    
    def save_migration
      migration_class = MigrationDefs::MigrationClass.new(params[:class_name], params[:parent_name])
      migration_class.parse_from_params params
      
      parsed_migration = RubyParser.new.parse(migration_class.get_str)
      @context = Ruby2Ruby.new.process(parsed_migration)
      
      open(Rails.root.to_s + '/db/migrate/' + params[:id] + '.rb', 'w') do |f|
        f.write(@context)
      end

      edit_migration
    end
    
    def direct_edit
      show_migrations
      
      if !params[:id].nil?
        migration_filename = Rails.root.to_s + '/db/migrate/' + params[:id] + '.rb'
        @migration_content = ''
        open(migration_filename, 'r') do |f|
          @migration_content = f.read
        end
      end
      
      begin
        @mi_lex = Ripper.lex(@migration_content)
      rescue
      end
      
      @edit_mode = 'direct_edit'
      render :direct_edit
    end
    
    def direct_save
      if !params[:migration].blank?
        migration_filename = Rails.root.to_s + '/db/migrate/' + params[:id] + '.rb'
        open(migration_filename, 'w') do |f|
          f.write params[:migration]
        end
      end
      
      direct_edit
    end
    
    def modify_table
      show_tables
      
      render :modify_table
    end
    
    def add_migration
      modify_table
    end
    
    def command_line
      render :command_line
    end

    def run_command
      command = params[:content]
      if (command =~ /rake .*/) || (command =~ /rails .*/) || (command =~ /git .*/)
        begin
          content = `#{command}`
        rescue
          content = '<font color="red">failed</font>'
        end
      else
        content = '<font color="red">available commands are "rake", "rails" and "git".</font>'
      end

      render :text => self.class.helpers.nl2br(content)
    end
  
  end
end
