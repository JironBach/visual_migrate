module VisualMigrate
  module ApplicationHelper
    def nl2br(str)
      str.gsub(/\r\n|\r|\n/, "<br />")
    end
    
    def method_select(id, select)
      select_tag(id, options_for_select(MigrationDefs::MethodName, select))
    end
    
    def func_select(id, select)
      select_tag(id, options_for_select(MigrationDefs::FuncName, select))
    end
    
    def show_class(migration_class)
      @migration_class = migration_class
      render :partial => "layouts/visual_migrate/migration_class"#Why???
    end
    
    def show_method(migration_method)
      @migration_method = migration_method
      @enable = true
      render :partial => "layouts/visual_migrate/migration_method"#Why???
    end
    
    def show_disabled_method(migration_method)
      @migration_method = migration_method
      @enable = false
      render :partial => "layouts/visual_migrate/migration_method"#Why???
    end
    
    def show_func(migration_func)
      @migration_func = migration_func
      if @migration_func.is_a? MigrationDefs::CreateTableFunc
        render :partial => "layouts/visual_migrate/func_create_table"#Why???
      end
    end
    
    def show_columns(func_name, columns)
      @func_name = func_name
      @columns = columns
      render :partial => "layouts/visual_migrate/columns"#Why???
    end

    def column_select(id, select)
      select_tag(id, options_for_select(MigrationDefs::ColumnType.keys, select))
    end
    
  end
end
