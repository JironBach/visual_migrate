require_dependency "visual_migrate/application_controller"

require 'pathname'

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
      
      if !params[:id].nil?
        open(Rails.root.to_s + '/db/migrate/' + params[:id], 'r') do |f|
          @migration_content = f.gets
        end
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
