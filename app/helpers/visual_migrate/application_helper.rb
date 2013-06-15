module VisualMigrate
  module ApplicationHelper
    def nl2br(str)
      str.gsub(/\r\n|\r|\n/, "<br />")
    end
    
    def method_select(id, select)
      select_tag(id, options_for_select(MigrateDefs::MethodNames, select))
    end
    
    def func_select(id, select)
      select_tag(id, options_for_select(MigrateDefs::FuncNames, select))
    end
    
    def show_method(migrate_method_class)
      @mmc = migrate_method_class
      @enable = true
      render :partial => "layouts/visual_migrate/migrate_method"#Why???
    end
    
    def show_disabled_method(migrate_method_class)
      @mmc = migrate_method_class
      @enable = false
      render :partial => "layouts/visual_migrate/migrate_method"#Why???
    end
    
    def show_func(migrate_func_class)
      @func = migrate_func_class
      if @func.is_a? MigrateDefs::CreateTableFunc
        render :partial => "layouts/visual_migrate/func_create_table"#Why???
      end
    end
    
    def show_columns(columns)
      @columns = columns
      render :partial => "layouts/visual_migrate/columns"#Why???
    end

    def column_select(id, select)
      select_tag(id, options_for_select(MigrateDefs::ColumnType.keys, select))
    end
    
  end
end
