# -*- coding: utf-8 -*-

module MigrationDefs
  MethodName = ['change', 'up', 'down']

  FuncName = {
      'create_table' => 'テーブルの作成',
      'rename_table' => 'テーブル名を変更',
      'drop_table' => 'テーブルの削除',
      #'change_table' => 'テーブル定義を変更',#not support
      'add_column' => 'カラムの追加',
      'rename_column' => 'カラム名の変更',
      'change_column' => 'カラムの変更カラムの変更',
      'remove_column' => 'カラムの削除',
      #'remove_columns' => '複数のカラムを削除',#not support
      'change_column_default' => 'カラムの初期値を設定',
      'add_index' => 'インデックスの追加',
      'rename_index' => 'インデックスの変更',
      'remove_index' => 'インデックスの削除',
      #'timestamps' => 'created_atとupdated_atを生成',#@create_table
      'add_timestamps' => 'created_atとupdated_atを追加',
      'remove_timestamps' => 'created_atとupdated_atの削除',
  }

  ColumnType = {
    'string' => '文字列',
    'text' => '長い文字列',
    'integer' => '整数',
    'float' => '浮動小数',
    'decimal' => '精度の高い小数',
    'datetime' => '日時',
    'timestamp' => 'より細かい日時',
    'time' => '時間',
    'date' => '日付',
    'binary' => 'バイナリデータ',
    'boolean' => 'Boolean型',
    'timestamps' => 'レコードの作成・更新日時'
  }
 
  class MigrationClass
    attr_accessor :name, :parent, :methods
    
    def initialize(name, parent_name = nil)
      @name = name
      @parent = parent_name
      @methods = Hash.new
    end
    
    def parse_from_params(parse_params)
      return '' if parse_params[:methods].nil?
      
      parse_params[:methods].each do |key, val|
        add_method(key) if val[:enable] == 'true'
      end
      parse_params[:methods].each do |p_key, p_val|#not DRY
        @methods.each do |m_key, m_val|
          m_val.parse_from_params(p_val) if p_key == m_key
        end
      end
    end
    
    def add_method(name)
      @methods[name] = MigrationMethod.new(name)
    end
    
    def get_str
      return if @name.nil?
      
      result = 'class ' + @name + (@parent.nil? ? '' : '< ' + @parent) + "\n"
      @methods.each do |key, val|
        result += val.get_str
      end
      result += "end\n"
    end
  end
  
  class AbstractMigrationClass
    #abstract_method :get_str, '(str -> String)' #undefined method `abstract_method' for MigrationDefs::AbstractMigrationClass:Class
    #abstract_method :parse_from_params, '(str -> String)'
  end
  
  class MigrationMethod < AbstractMigrationClass
    attr_accessor :name, :funcs
    
    def initialize(name)
      return nil if !MethodName.include? name
      
      @name = name
      @funcs = Hash.new
    end

    def add_func(name, func_name, *func_options)
      @funcs[func_name] = FuncFactory::get(name, func_name, func_options)
    end
    
    def parse_from_params(parse_params)
      return '' if parse_params[:funcs].nil?
      
      parse_params[:funcs].each do |key, val|
        add_func(val[:name], val[:table_name]) if val[:delete] != 'true'
      end
      parse_params[:funcs].each do |p_key, p_val|#not DRY
        @funcs.each do |m_key, m_val|
          m_val.parse_from_params(p_val) if p_key == m_key
        end
      end
    end
    
    def get_str
      result = 'def ' + @name + "\n"
      @funcs.each do |key, val|
        result += val.get_str if !val.nil?
      end
      result += "end\n"
    end
  end
  
  class FuncFactory
    def self.get(func_type, func_name, *func_options)#How do I dynamic params?
      case func_type
      when 'create_table'
        return CreateTableFunc.new(func_name)
      when 'rename_table'
        return RenameTableFunc.new(func_name)
      when 'drop_table'
        return DropTableFunc.new(func_name)
      when 'add_column'
        return AddColumnFunc.new(func_name)
      when 'rename_column'
      when 'change_column' 
      when 'remove_column'
      when 'change_column_default'
      when 'add_index'
      when 'rename_index'
      when 'remove_index'
      when 'add_timestamps'
      when 'remove_timestamps'
      else
        return nil
      end
    end
  end
  
  class ColumnOption < AbstractMigrationClass
    attr_accessor :limit, :default, :null, :precision, :scale
    
    Description = {
      'limit' => 'カラムの桁数', 
      'default' => 'デフォルトの値',
      'null' => 'nullを許可するか', 
      'precision' => '数値の桁数',
      'scale' => '小数点以下の桁数',
    }

    def initialize(limit = nil, default = nil, is_null = true, precision = nil, scale = nil)
      @limit = limit
      @default = default
      @null	= is_null
      @precision = precision
      @scale = scale
	  end
    
    def get_str
      result = ''
      result += ', :limit => ' + @limit.to_s if !@limit.blank? && @limit != 0
      result += ', :default => ' + @default.to_s if !@default.blank?
      result += ', :null => ' + @null.to_s if !@null
      result += ', :precision => ' + @precision.to_s if !@precision.nil? && @precision != 0
      result += ', :scale => ' + @scale.to_s if !@scale.nil? && @scale != 0
      result
    end
  end

  class Column < AbstractMigrationClass
    attr_accessor :name, :type, :option
    
    def initialize(type, name = '', *p_option)
      return nil if !ColumnType.has_key?(type)
      
      @type = type
      @name = name
      @option = ColumnOption.new
    end
    
    def set_option(key, val)
      case key
      when 'limit'
        @option.limit = val.to_i
      when 'default'
        @option.default = val
      when 'null'
        @option.null = (val == 'true')
      when 'precision'
        @option.precision = val.to_i
      when 'scale'
        @option.scale = val.to_i
      end
    end
    
    def get_str
      result = 't.' + @type
      result += ' :' + @name if @type != 'timestamps'
      result += @option.get_str
    end
  end
  
  class CreateTableOption < AbstractMigrationClass
    attr_accessor :id, :primary_key, :options, :temporary, :force

    Description = {
      'id' => '主キーを自動生成', 
      'primary_key' => '主キーのカラムの名前',
      'options' => 'テーブルオプション', 
      'temporary' => '一時テーブルとして作成',
      'force' => 'テーブルを作成前に、既存のテーブルを削除',
    }
    
    def initialize(id = true, primary_key = 'id', options = nil, temporary = false, force = true)
      @id = id
      @primary_key = primary_key
      @options = options
      @temporary = temporary
      @force = force
    end
    
    def set_option(key, val)
      case key
      when 'id'
        @id = (val == 'true')
      when 'primary_key'
        @primary_key = val
      when 'options'
        @options = val
      when 'temporary'
        @temporary = (val == 'true')
      when 'force'
        @force = (val == 'true')
      end
    end
    
    def get_str
      result = ''
      result += ', ' + ':id => ' + @id.to_s if !@id.nil? && !@id
      result += ', ' + ':primary_key => ' + @primary_key if @primary_key != 'id'
      result += ', ' + ':options => ' + @options if !@options.nil? && !@options.blank?
      result += ', ' + ':temporary => ' + @temporary if !@temporary.nil? && @temporary != false
      result += ', ' + ':force => ' + @force if !@force.nil? && @force != true
      result
    end
  end

  class CreateTableFunc < AbstractMigrationClass
    attr_accessor :name, :option, :columns
    
    def initialize(name)
      @name = name
      @option = CreateTableOption.new
      @columns = Array.new
    end
    
    def add_column(type, name = '')
      @columns << Column.new(type, name)
      @columns.last
    end
    
    def parse_from_params(parse_params)
      return '' if parse_params.nil? || parse_params[:columns].nil?
      
      parse_params.each do |key, val|
        @option.set_option(key, val)
      end
      
      parse_params[:columns].each do |key, val|
        next if val.nil?
        
        if val[:type] != 'timestamps'
          c = add_column(val[:type], val[:name])
          c.set_option 'limit', val[:limit]
          c.set_option 'default', val[:default]
          c.set_option 'null', val[:null]
          c.set_option 'precision', val[:precision]
          c.set_option 'scale', val[:scale]
        else
          add_column(val[:type])
        end
      end
    end
    
    def get_str
      result = 'create_table :' + @name
      result += @option.get_str if !@option.nil?
      result += " do |t|\n"
      @columns.each do |col|
        result += col.get_str + "\n" if !col.nil?
      end
      result += "end\n"
    end
  end

=begin
  class ChangeTableOption < AbstractMigrationClass
    attr_accessor :name, :column, :value
    
    Description = {
      'index' => 'インデックス',
      'change' => 'カラムを変更',
      'change_default' => 'カラムのデフォルト値を変更',
      'rename' => 'カラムの名前を変更',
      'remove' => 'カラムを削除',
      'remove_references' => 'リファレンスの削除',
      'remove_index' => 'インデックスの削除',
      'remove_timestamps' => 'タイムスタンプの削除',
    }

    def initialize(name, column, value = nil)
      return nil if !Description.has_key?(name)
      
      @name = name
      @column = column
      @value = value
    end
    
    def get_str
      result = 't.' + @name + ' :' + @column
      result += ', :' + @value if !@value.blank?
      result
    end
  end

  class ChangeTableFunc < AbstractMigrationClass
    attr_accessor :name, :option, :options
    
    def initialize(name)
      @name = name
      #@option = {:bulk => false}
      @options = Array.new
    end
    
    def add_option(option, column, value = nil)
      @options << ChangeTableOption.new(option, column, value)
      @options.last
    end
    
    def parse_from_params(parse_params)
      return '' if parse_params.nil? || parse_params[:options].nil?
      
      parse_params[:options].each do |key, val|
        puts val
        next if val.nil?
        
        add_option(val[:name], val[:column], val[:value])
      end
    end
    
    def get_str
      result = 'change_table :' + @name
      #result += @option.get_str if !@option.nil?
      result += " do |t|\n"
      @options.each do |opt|
        result += opt.get_str + "\n" if !opt.nil?
      end
      result += "end\n"
    end
  end
=end
  
  class RenameTableFunc < AbstractMigrationClass
    attr_accessor :name, :new_name
    
    def initialize(name)
      @name = name
    end
    
    def add_new_name(new_name)
      @new_name = new_name
    end
    
    def parse_from_params(parse_params)
      @new_name = parse_params[:new_table_name]
    end
    
    def get_str
      'rename_table :' + @name + (@new_name.nil? ? '' : ', :' + @new_name) + "\n"
    end
  end

  class DropTableFunc < AbstractMigrationClass
    attr_accessor :name
    
    def initialize(name)
      @name = name
    end
    
    def parse_from_params(parse_params)
      return ''
    end
    
    def get_str
      'drop_table :' + @name + "\n"
    end
  end

  class AddColumnFunc < AbstractMigrationClass
    attr_accessor :column
    
    def initialize(name)
      @name = name
      @option = ColumnOption.new
    end
    
    def add_column(type, name = '')
      Column.new(type, name)
    end
    
    def parse_from_params(parse_params)
      if parse_params[:type] != 'timestamps'
        @column = add_column(parse_params[:type], parse_params[:column])
        @column.set_option 'limit', parse_params[:limit]
        @column.set_option 'default', parse_params[:default]
        @column.set_option 'null', parse_params[:null]
        @column.set_option 'precision', parse_params[:precision]
        @column.set_option 'scale', parse_params[:scale]
      else
        add_column(parse_params[:type])
      end
    end
    
    def get_str
      if @column.type != 'timestamps'
        return 'add_column :' + @name + ', :' + @column.name + ', :' + @column.type +
              ', :limit => ' + @column.limit +
              ', :default' + @column.default +
              ', :null' + @column.null +
              ', :precision' + @column.precision +
              ', :scale' + @column.scale +
              "\n"
      else
        return "add_column :timestamps\n"
      end
    end
  end

end
