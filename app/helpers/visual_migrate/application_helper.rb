module VisualMigrate
  module ApplicationHelper
    def nl2br(str)
      str.gsub(/\r\n|\r|\n/, "<br />")
    end
    
    def method_select(id, select = nil)
      select_tag(id, options_for_select(MigrationDefs::MethodName, select))
    end
    
    def func_select(id, select = nil)
      select_tag(id, options_for_select(MigrationDefs::FuncName.keys, select), :prompt => 'Select')
    end
 
=begin
    def change_table_option_select(id, select = nil)
      select_tag(id, options_for_select(MigrationDefs::ChangeTableOption::Description.keys, select))
    end
=end

    def tables_select(table_id, select = nil)
      select_tag(table_id, options_for_select(ActiveRecord::Base.connection.tables, select), :prompt => 'Select or input')
    end
    
    def tables_select_with_ajax(table_id, update_div, method_id, func_id, table_select = nil, column_select = nil)
      select_tag(table_id, options_for_select(ActiveRecord::Base.connection.tables, table_select), :prompt => 'Select table',
=begin
        data : {
          remote : true,
          url : url_for(:action => :show_select_columns, :id => column_id),
          type : "GET",
          dataType : 'html',
          data : {:table_name => table_id, :column_select => column_select},
          update : update_div,
        })
=end
        :onchange => "updateColumnsDiv(this.value, " + update_div + ", '" + method_id + "', '" + func_id + "');")
    end
    
    def columns_select(column_id, table, select = nil)
      select_tag(column_id, options_for_select(Kernel.const_get(table.singularize.camelize).column_names, select))
    end
    
    def show_class(migration_class)
      @migration_class = migration_class
      render :partial => "layouts/visual_migrate/migration_class"#Why???
    end
    
    def show_method(migration_method)
      @migration_method = migration_method
      @enable = true
      render :partial => "layouts/visual_migrate/migration_method"
    end
    
    def show_disabled_method(migration_method)
      @migration_method = migration_method
      @enable = false
      render :partial => "layouts/visual_migrate/migration_method"
    end
    
    def show_func(migration_func)
      @migration_func = migration_func
      if @migration_func.is_a? MigrationDefs::CreateTableFunc
        render :partial => "layouts/visual_migrate/func_create_table"
      elsif @migration_func.is_a? MigrationDefs::DropTableFunc
        render :partial => "layouts/visual_migrate/func_drop_table"
      #elsif @migration_func.is_a? MigrationDefs::ChangeTableFunc
      #  render :partial => "layouts/visual_migrate/func_change_table"
      elsif @migration_func.is_a? MigrationDefs::RenameTableFunc
        render :partial => "layouts/visual_migrate/func_rename_table"
      end
    end
    
    def show_columns(columns)
      @columns = columns
      render :partial => "layouts/visual_migrate/columns"
    end

    def column_select(id, select)
      select_tag(id, options_for_select(MigrationDefs::ColumnType.keys, select))
    end
    
=begin
    def show_change_table_options(options)
      @options = options
      render :partial => "layouts/visual_migrate/change_table_options"
    end
=end
    
  end
end
