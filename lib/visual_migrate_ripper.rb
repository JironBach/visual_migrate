# -*- coding: utf-8 -*-

require 'ripper'
require 'migrate_defs'

class VisualMigrateRipper < Ripper::Filter
  attr_reader :class_name, :parent_name, :method_classes
  
  def initialize(src)
    super src
    
    @method_classes = Array.new
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
 
    if @is_func
      if !@func_type.nil?
        @func_class = @method_class.add_func(@func_type, tok)
        @func_type = nil
      elsif tok == 'timestamps'
        @func_class.add_column(tok)
      elsif MigrateDefs::ColumnType::Description.has_key?(tok)
        @column_type = tok
        @is_column = true
      elsif @is_column
        @func_class.add_column(@column_type, tok)
      end
    elsif @method_name.nil? && MigrateDefs::FuncNames.include?(tok)
      @func_type = tok
      @is_func = true
    elsif @def_name.nil? && MigrateDefs::MethodNames.include?(tok)
      @def_name = tok
      @method_class = MigrateDefs::MigrateMethod.new(tok)
      @method_classes << @method_class
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
      @is_ancestors = false
      @is_super = false
      @is_class = false
    end
  end
  
  def on_do_block(tok, f)
    @is_do = true
  end
  
  def get_str
    result = 'class ' + @class_name
    result += ' < ' + @parent_name + "\n" if !@parent_name.nil?
    @method_classes.each do |mc|
      result += mc.get_str
    end
    result += "end"
    result
  end
end
