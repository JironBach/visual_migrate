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
      'change_column' => 'カラムの変更',
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
    'timestamps' => 'レコードの作成・更新日時',
    'attachment' => 'attachment',
    'belongs_to' => 'belongs_to',
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
      @funcs = Array.new
    end

    def add_func(name, func_name, *func_options)
      @funcs << FuncFactory::get(name, func_name, func_options)
    end

    def parse_from_params(parse_params)
      return '' if parse_params[:funcs].nil?

      parse_params[:funcs].each do |val|
        add_func(val[:name], val[:table_name]) if val[:delete] != 'true'
      end
      index = 0
      parse_params[:funcs].each do |val|#not DRY
        if val[:delete] != 'true'
          @funcs[index].parse_from_params(val)
          index += 1
        end
      end
    end

    def get_str
      result = "def #{@name}\n"
      @funcs.each do |func|
        result += func.get_str if !func.nil?
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
        return RenameColumnFunc.new(func_name)
      when 'change_column'
        return ChangeColumnFunc.new(func_name)
      when 'remove_column'
        return RemoveColumnFunc.new(func_name)
      when 'change_column_default'
        return ChangeColumnDefaultFunc.new(func_name)
      when 'add_index'
        return AddIndexFunc.new(func_name)
      when 'rename_index'
        return RenameIndexFunc.new(func_name)
      when 'remove_index'
        return RemoveIndexFunc.new(func_name)
      when 'add_timestamps'
        return AddTimestampsFunc.new(func_name)
      when 'remove_timestamps'
        return RemoveTimestampsFunc.new(func_name)
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

    def initialize(limit = nil, default = nil, is_null = false, precision = nil, scale = nil)
      @limit = limit
      @default = default
      @null	= is_null
      @precision = precision
      @scale = scale
	  end

    def get_str
      result = ''
      result += ", :limit => #{@limit.to_s}" if !@limit.blank? && @limit != 0
      result += ", :default => #{@default.to_s}" if !@default.blank?
      result += ", :null => #{@null.to_s}" if !@null.blank?
      result += ", :precision => #{@precision.to_s}" if !@precision.nil? && @precision != 0
      result += ", :scale => #{@scale.to_s}" if !@scale.nil? && @scale != 0
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

    def get_str(prefix = 't.')
      result = prefix + @type
      result += " :#{@name}" if (@type != 'timestamps') && (@type != 'attachment') && (@type != 'belongs_to')
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

    def initialize(id = true, primary_key = 'id', options = nil, temporary = false, force = false)
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
      result += ", :id => #{@id.to_s}" if !@id.nil? && !@id
      result += ", :primary_key => #{@primary_key}" if @primary_key != 'id'
      result += ", :options => #{@options}" if !@options.nil? && !@options.blank?
      result += ", :temporary => #{@temporary.to_s}" if !@temporary.nil? && @temporary != false
      result += ", :force => #{@force.to_s}" if !@force.nil? && @force != true
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

        if (val[:type] != 'timestamps') && (val[:type] != 'attachment') && (val[:type] != 'belongs_to')
          c = add_column(val[:type], val[:name])
          c.set_option 'limit', val[:limit]
          c.set_option 'default', val[:default]
          c.set_option 'null', val[:null]
          c.set_option 'precision', val[:precision]
          c.set_option 'scale', val[:scale]
        else
          c = add_column(val[:type])
        end
      end
    end

    def get_str
      result = "create_table :#{@name}"
      result += @option.get_str if !@option.nil?
      result += " do |t|\n"
      @columns.each do |col|
        result += col.get_str + "\n" if !col.nil?
      end
      result += "end\n"
    end
  end

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
      "rename_table :#{@name}" + (@new_name.blank? ? '' : ":#{@new_name}") + "\n"
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
    attr_accessor :name, :column

    def initialize(name)
      @name = name
    end

    def add_column(type, name = '')
      @column = Column.new(type, name)
    end

    def parse_from_params(parse_params)
      if (parse_params[:type] != 'timestamps') && (parse_params[:type] != 'attachment') && (parse_params[:type] != 'belongs_to')
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
      if @column.nil?
          return "add_column :#{@name}\n"
      else
        if (@column.type != 'timestamps') && (@column.type != 'attachment') && (@column.type != 'belongs_to')
          return "add_column :#{@name}" + (@column.name.blank? ? "\n" : ", :#{@column.name}, :#{@column.type}#{@column.option.get_str}\n")
        else
          return "add_column :#{@name}, #{:@column.type}\n"
        end
      end
    end
  end

  class RemoveColumnFunc < AbstractMigrationClass
    attr_accessor :name, :column_name

    def initialize(name)
      @name = name
    end

    def add_column_name(column_name)
      @column_name = column_name
    end

    def parse_from_params(parse_params)
      @column_name = parse_params[:column_name]
    end

    def get_str
      "remove_column :#{@name}" + (@column_name.blank? ? '' : ", :#{@column_name}") + "\n"
    end
  end

  class RenameColumnFunc < AbstractMigrationClass
    attr_accessor :name, :column_name, :new_column_name

    def initialize(name)
      @name = name
    end

    def add_column_name(column_name)
      @column_name = column_name
    end

    def add_new_column_name(column_name)
      @new_column_name = column_name
    end

    def parse_from_params(parse_params)
      @column_name = parse_params[:column_name]
      @new_column_name = parse_params[:new_column_name]
    end

    def get_str
      "rename_column :#{@name}" + (@column_name.blank? ? '' : ", :#{@column_name}") + (@new_column_name.blank? ? '' : ", :#{@new_column_name}") + "\n"
    end
  end

  class ChangeColumnFunc < AddColumnFunc
    def get_str
      if @column.nil?
          return "change_column :#{@name}\n"
      else
        if (@column.type != 'timestamps') && (@column.type != 'attachment') && (@column.type != 'belongs_to')
          return "change_column :#{@name}" + (@column.name.blank? ? "\n" : ", :#{@column.name}, :#{@column.type}#{@column.option.get_str}\n")
        else
          return "change_column :#{@name}, #{:@column.type}\n"
        end
      end
    end
  end

  class ChangeColumnDefaultFunc < AbstractMigrationClass
    attr_accessor :name, :column_name, :default

    def initialize(name)
      @name = name
    end

    def add_column_name(column_name)
      @column_name = column_name
    end

    def set_column_default(default)
      @default = default
    end

    def parse_from_params(parse_params)
      Rails.logger.debug parse_params.inspect
      @column_name = parse_params[:column_name]
      @default = parse_params[:default]
    end

    def get_str
      "change_column_default :#{@name}" + (@column_name.blank? ? '' : ", :#{@column_name}") + (@default.blank? ? '' : ", #{@default}") + "\n"
    end
  end

  class IndexOption < AbstractMigrationClass
    attr_accessor :name, :unique, :length

    Description = {
      'name' => 'インデックスの名前',
      'unique' => 'ユニークなインデックス',
      'length' => 'インデックスに含まれるカラムの長さ',
    }

    def initialize(name = "''", unique = nil, length = nil)
      @name = name
      @unique = unique
      @length = length
    end

    def set_option(key, val)
      case key
      when 'name'
        @name = val
      when 'unique'
        @unique = (val == 'true')
      when 'length'
        @length = !val.blank? ? val.to_i : nil
      end
    end

    def get_str
      result = ''
      result += ", :name => #{@name}" if !@name.nil? && !@name.blank?
      result += ", :unique => #{@unique.to_s}" if !@unique.nil?
      result += ", :length => #{@length.to_s}" if !@length.nil?
      result
    end
  end

  class AddIndexFunc < AbstractMigrationClass
    attr_accessor :name, :columns, :option

    def initialize(name)
      @name = name
      @columns = '[]'
      @option = IndexOption.new
    end

    def set_columns(val)
      @columns = val
    end

    def parse_from_params(parse_params)
      @columns = set_columns(parse_params[:columns])
      @option.set_option 'name', parse_params[:index_name]
      @option.set_option 'unique', parse_params[:unique]
      @option.set_option 'length', parse_params[:length]
    end

    def get_str
      result = 'add_index '
      result += " :#{@name}" if !@name.nil? && !@name.blank?
      result += ", #{@columns}" if !@columns.nil? && !@columns.blank?
      result += " #{@option.get_str}"
      result += "\n"
      result
    end
  end

  class RemoveIndexOption < AbstractMigrationClass
    attr_accessor :name, :column

    Description = {
      'name' => 'インデックスの名前',
      'column' => 'カラム',
    }

    def initialize(name = "''", column = "[]")
      @name = name
      @column = column
    end

    def set_option(key, val)
      case key
      when 'name'
        @name = val
      when 'column'
        @column = val
      end
    end

    def get_str
      result = ''
      result += ", :name => #{@name}" if !@name.nil? && !@name.blank?
      result += ", :column => #{@column}" if !@column.nil? && !@column.blank?
      result
    end
  end

  class RemoveIndexFunc < AbstractMigrationClass
    attr_accessor :name, :option

    def initialize(name)
      @name = name
      @option = RemoveIndexOption.new
    end

    def parse_from_params(parse_params)
      @option.set_option 'name', parse_params[:index_name]
      @option.set_option 'column', parse_params[:columns]
    end

    def get_str
      return "remove_index :#{@name} #{@option.get_str}\n"
    end
  end

  class RenameIndexFunc < AbstractMigrationClass
    attr_accessor :name, :index_name, :new_index_name

    def initialize(name)
      @name = name
      @index_name = "''"
      @new_index_name = "''"
    end

    def parse_from_params(parse_params)
      @index_name = parse_params[:index_name]
      @new_index_name = parse_params[:new_index_name]
    end

    def get_str
      result = "rename_index :#{@name}"
      result += ", #{@index_name}" if !@index_name.nil? && !@index_name.blank?
      result += ", #{@new_index_name}" if !@new_index_name.nil? && !@new_index_name.blank?
      result += "\n"
    end
  end

  class AddTimestampsFunc < AbstractMigrationClass
    attr_accessor :name

    def initialize(name)
      @name = name
    end

    def parse_from_params(parse_params)
    end

    def get_str
      return "add_timestamps :#{@name}\n"
    end
  end

  class RemoveTimestampsFunc < AddTimestampsFunc
    def get_str
      return "remove_timestamps :#{@name}\n"
    end
  end

end
