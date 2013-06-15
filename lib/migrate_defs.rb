# -*- coding: utf-8 -*-

module MigrateDefs
  MethodNames = Array.new(['change', 'up', 'down'])

  FuncNames = Array.new([
      'create_table',
      'drop_table',
      'change_table',
      'rename_table',
      'add_column',
      'rename_column',
      'change_column',
      'remove_column',
      'add_index',
      'remove_index',
  ])

  class AbstractMigrateMethod
    #abstract_method :get_str, '(str -> String)' #undefined method `abstract_method' for MigrateDefs::AbstractMigrateMethod:Class
  end
  
  class MigrateMethod < AbstractMigrateMethod
    attr :name, :funcs
    
    def initialize(name)
      return nil if !MethodNames.include? name
      
      @name = name
      @funcs = Array.new
    end

    def add_func(func_type, name, *func_options)
      funcs << FuncFactory::get(func_type, name, func_options)
      funcs.last
    end
    
    def get_str
      result = 'def ' + @name + "\n"
      funcs.each do |func|
        result += func.get_str
      end
      result += "end\n"
      result
    end
  end
  
  class FuncFactory
    def self.get(func_type, name, *func_options)
      case func_type
      when 'create_table'
        return CreateTableFunc.new(name)#, func_options)#How do I dynamic params?
      else
        return nil
      end
    end
  end
  
  class ColumnOption < AbstractMigrateMethod
    attr :limit, :default, :null, :precision, :scale
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
      result += ':limit => ' + @limit if !@limit.nil?
      result += !result.blank? ? ', ' : '' + ':default => ' + @default if !@default.nil?
      result += !result.blank? ? ', ' : '' + ':null => ' + @null.to_s if !@null
      result += ', :precision => ' + @precision if !@precision.nil?
      result += ', :scale => ' + @scale + "\n" if !@scale.nil?
      result
    end
  end

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
 
  class Column < AbstractMigrateMethod
    attr :name, :type, :option
    
    def initialize(type, name = '', option = ColumnOption.new)
      return nil if !ColumnType.has_key?(type)

      @type = type
      @name = name
      @option = option
    end
    
    def get_str
      result = 't.' + @type
      result += ' ' + @name
      result += @option.get_str + "\n"
      result
    end
  end
  
  class CreateTableOption < AbstractMigrateMethod
    attr :id, :primary_key, :options, :temporary, :force
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
    
    def get_str
      result = ''
      result += ':create_id => ' + @id.to_s if !@id
      result += result.blank? ? '' : ', ' + ':primry_key => ' + @primary_key if @primary_key != 'id'
      result += result.blank? ? '' : ', ' + ':options => ' + @options if !@options.nil?
      result += result.blank? ? '' : ', ' + ':temporary => ' + @temporary if @temporary
      result += result.blank? ? '' : ', ' + ':force => ' + @force + "\n" if !@force
      result
    end
  end

  class CreateTableFunc < AbstractMigrateMethod
    attr :name, :options, :columns
    
    def initialize(name, id = true, primary_key = 'id', options = nil, temporary = false, force = true)
      @name = name
      @options = CreateTableOption.new(id, primary_key, options, temporary, force)
      @columns = Array.new
    end
    
    def add_column(type, name = '')
      @columns << Column.new(type, name)
      @columns.last
    end
    
    def get_str
      result = 'create_table :' + @name
      result += @options.get_str
      result += " do |t|\n"
      @columns.each do |col|
        result += col.get_str
      end
      result += "end\n"
      result
    end
  end
end
