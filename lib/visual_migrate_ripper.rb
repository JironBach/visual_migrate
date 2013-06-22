# -*- coding: utf-8 -*-

require 'ripper'
require 'migration_defs'

class VisualMigrateRipper < Ripper::Filter
  attr_reader :class
  
  def initialize(src)
    super src
    
    @is_class = false
    @is_method = false
    @is_func = false
    @is_do = false
  end

  def on_kw(tok, f)
    if tok == 'class'
      @is_class = true
    elsif tok == 'def'
      @is_method = true
    elsif tok == 'end'
      if @is_do
        @is_do = false
      elsif @is_func
        @is_func = false
      elsif @is_method
        @is_method = false
      end
    end
  end

  def on_ident(tok, f)
    return if tok == 't'

    if @is_column
      if !@column_type.nil?
        @class.methods[@method_name].funcs[@func_name].add_column(@column_type, tok)
        @column_name = tok
        @is_option = true
        @column_type = nil
      elsif @option_name.nil?
        @option_name = tok
        @is_option = true
      elsif @is_option
        @class.methods[@method_name].funcs[@func_name].columns(@column_name).options[@option_name] = tok
        @option_name = nil
      end
    elsif @is_func
      if !@func_type.nil?
        @func_class = @class.methods[@method_name].add_func(@func_type, tok)
        @func_name = tok
        @func_type = nil
      elsif tok == 'timestamps'
        @class.methods[@method_name].funcs[@func_name].add_column(tok)
      elsif !@column_type.nil?
        @class.methods[@method_name].funcs[@func_name].add_column(@column_type, tok)
        @column_type = nil
      elsif MigrationDefs::ColumnType.has_key?(tok)
        @column_type = tok
        @is_column = true
      end
    elsif !@method_name.nil? && MigrationDefs::FuncName.include?(tok)
      @func_type = tok
      @is_func = true
    elsif @method_name.nil? && MigrationDefs::MethodName.include?(tok)
      @method_name = tok
      @class.add_method(tok)
    end
  end
  
  def on_const(tok, f)
    if @is_ancestors
      @parent_name += '::' + tok
    elsif @is_super
      @parent_name = tok
    elsif @is_class
      @class_name = tok
    end
    puts @parent_name
  end
  
  def on_op(tok, f)
    if tok == '<'
      @is_super = true
    elsif @is_super && tok == '::'
      @is_ancestors = true
    end
  end
  
  def on_nl(tok, f)
    if @is_class
      @class = MigrationDefs::MigrationClass.new(@class_name, @parent_name)
      @is_class = false
      @is_ancestors = false
      @is_super = false
    elsif !@on_comma
      @is_option = false
    end
  end
  
  def on_do_block(tok, f)
    @is_do = true
  end
  
  def on_comma(tok, f)
    @on_comma = true
    @is_option = true
  end
  
  def on_tstring_content(tok, f)
    if @is_option && !@option_name.nil?
      @class.methods[@method_name].funcs[@func_name].columns.last.set_option(@option_name, tok)
      @option_name = nil
    end
  end
end
