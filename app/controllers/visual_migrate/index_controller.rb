# -*- coding: utf-8 -*-

require_dependency "visual_migrate/application_controller"

require 'pathname'
require 'migration_defs'
require 'class_filter'

module VisualMigrate
  include ApplicationHelper

  class IndexController < ApplicationController
    def show_migrations
      @section_category = :migrations
      
      d = Pathname(Rails.root.to_s + '/db/migrate/')
      files = d.children
      @migration_files = []
      files.each do |f|
        @migration_files << f if f.extname == '.rb' && f.basename.to_s !~ /\.visual_migrate\./
      end
    end
    
    def show_tables
      @section_category = :tables
      @tables = ActiveRecord::Base.connection.tables
    end
    
    def show_select_columns
      render :text => self.class.helpers.columns_select(
        '[methods][' + params[:method_name] + '][funcs][' + params[:func_name] + '][options][' + params[:row_num] + '][column]',
        params[:table_name], params[:column_select])
    end
    
    def index
      edit_migration
    end
    
    def edit_migration
      show_migrations
      
      if !params[:id].nil? || @tmp
        if !@tmp
          migration_filename = Rails.root.to_s + '/db/migrate/' + params[:id] + '.rb'
        else
          migration_filename = Rails.root.to_s + '/tmp/visual-migrate_tmp.rb'
        end
        @tmp = false
        
        migration_content = ''
        open(migration_filename, 'r') do |f|
          @migration_content = f.read
        end

        @mi_lex = Ripper.lex(@migration_content)
        vm_filter = ClassFilter.new @migration_content
        puts '-----vm_filter.parse-----' + @migration_content
        vm_filter.parse
        @context = vm_filter.class.get_str
        @vm_ripper = vm_filter
      end
      
      render :edit_migration
    end
    
    def save_migration
      migration_class = MigrationDefs::MigrationClass.new(params[:class_name], params[:parent_name])
      migration_class.parse_from_params params

      parsed_migration = RubyParser.new.parse(migration_class.get_str)
      @context = Ruby2Ruby.new.process(parsed_migration)#migration_class.get_str#migration_class.get_str#params.inspect#
      
      #@tmp = true
      #open(Rails.root.to_s + '/tmp/visual-migrate_tmp.rb', 'w') do |f|
      open(Rails.root.to_s + '/db/migrate/' + params[:id] + '.rb', 'w') do |f|
        f.write(@context)
      end

      edit_migration
    end
    
    def add_function
      migration_class = MigrationDefs::MigrationClass.new(params[:class_name], params[:parent_name])
      migration_class.parse_from_params params
      if !params[:new_func].nil?
        params[:new_func].each do |p_key, p_val|
          if !migration_class.methods.has_key?(p_key)
            migration_class.add_method(p_key) if p_val[:enable] == 'true'
          end
          migration_class.methods.each do |m_key, m_val|
            if !p_val[:new_table_name].blank?
              m_val.add_func(p_val[:type], p_val[:new_table_name]) if (p_key == m_key) && (p_val[:delete] != 'true')
            elsif !p_val[:table_name].blank?
              m_val.add_func(p_val[:type], p_val[:table_name]) if (p_key == m_key) && (p_val[:delete] != 'true')
            end
          end
        end
      end
      parsed_migration = RubyParser.new.parse(migration_class.get_str)
      @context = Ruby2Ruby.new.process(parsed_migration)#migration_class.get_str#params[:new_func].inspect#

      open(Rails.root.to_s + '/tmp/visual-migrate_tmp.rb', 'w') do |f|
        f.write(@context)
      end
      @tmp = true

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
    
    def command_line
      show_migrations
      
      render :command_line
    end

    def run_command
      command = params[:command_line]
      if (command =~ /^rake .*/) || (command =~ /^rails .*/) || (command =~ /^git .*/)
        #begin
          status, stdout, stderr = systemu command
          if stderr.blank?
            @run_result = stdout
          else
            @run_result = stdout + '<br /><font color="red">' + stderr + '</font>'
          end
          reset_session#db:migrate:down時にvalidationが走るのて
        #rescue
        #  @run_result = '<font color="red">failed</font>'
        #end
      else
        @run_result = '<font color="red">available commands are "rake", "rails" and "git".</font>'
      end

      command_line
    end
  
  end
end
