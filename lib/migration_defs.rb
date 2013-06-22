# -*- coding: utf-8 -*-

module MigrationDefs
  MethodName = ['change', 'up', 'down']

  FuncName = [
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
  ]

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
      parse_params[:methods].each do |key, val|
        add_method(key) if val[:enable] == 'true'
      end
      if !methods.blank?
        parse_params[:methods].each do |p_key, p_val|#not DRY
          @methods.each do |m_key, m_val|
            m_val.parse_from_params(p_val) if p_key == m_key
          end
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
  
  class AbstractMigrationMethod
    #abstract_method :get_str, '(str -> String)' #undefined method `abstract_method' for MigrationDefs::AbstractMigrationMethod:Class
    #abstract_method :parse_from_params, '(str -> String)'
  end
  
  class MigrationMethod < AbstractMigrationMethod
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
      parse_params[:funcs].each do |key, val|
        add_func(val[:name], val[:table_name])
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
        result += val.get_str
      end
      result += "end\n"
    end
  end
  
  class FuncFactory
    def self.get(func_type, func_name, *func_options)#How do I dynamic params?
      case func_type
      when 'create_table'
        result = CreateTableFunc.new(func_name)
        result.option.id = func_options[0]
        result.option.primary_key = func_options[1]
        result.option.options = func_options[2]
        result.option.temporary = func_options[3]
        result.option.force = func_options[4]
        result
      else
        return nil
      end
    end
  end
  
  class ColumnOption < AbstractMigrationMethod
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
      result = ' '
      result += ':limit => ' + @limit.to_s if !@limit.blank? && @limit != 0
      result += (!result.blank? ? ', ' : '') + ':default => ' + @default.to_s if !@default.blank?
      result += (!result.blank? ? ', ' : '') + ':null => ' + @null.to_s if !@null
      result += (!result.blank? ? ', ' : '') + ':precision => ' + @precision.to_s if !@precision.nil? && @precision != 0
      result += (!result.blank? ? ', ' : '') + ':scale => ' + @scale.to_s if !@scale.nil? && @scale != 0
      result
    end
  end

  class Column < AbstractMigrationMethod
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
      result += ' ' + @name
      result += @option.get_str
    end
  end
  
  class CreateTableOption < AbstractMigrationMethod
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
        @option.id = val
      when 'primary_key'
        @option.primary_key = val
      when 'options'
        @option.temporary = val
      when 'temporary'
        @option.temporary = val
      when 'force'
        @option.force = val
      end
    end
    
    def get_str
      puts self.inspect
      
      result = ''
      result += result.blank? ? '' : ', ' + ':id => ' + @id.to_s if !@id
      result += result.blank? ? '' : ', ' + ':primry_key => ' + @primary_key if @primary_key != 'id'
      result += result.blank? ? '' : ', ' + ':options => ' + @options if !@options.nil?
      result += result.blank? ? '' : ', ' + ':temporary => ' + @temporary if !@temporary.blank? && @temporary != 'false'
      result += result.blank? ? '' : ', ' + ':force => ' + @force if !@force.blank? && @force != 'true'
      result
    end
  end

  class CreateTableFunc < AbstractMigrationMethod
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
      puts parse_params[:columns].inspect
      
      parse_params[:columns].each do |key, val|
        if key != 'timestamps'
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
      result += @options.get_str if !@options.nil?
      result += " do |t|\n"
      @columns.each do |col|
        result += col.get_str + "\n"
      end
      result += "end\n"
    end
  end
end
