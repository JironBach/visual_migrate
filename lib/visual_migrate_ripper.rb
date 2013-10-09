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
      @is_func = false
    elsif tok == 'end'
      if @is_option
        @is_option = false
      elsif @is_do
        @is_do = false
      elsif @is_func
        @is_func = false
      elsif @is_method
        @is_method = false
      end
    elsif tok == 'true' || tok == 'false'
      if @is_option_option && !@option_option_name.nil?
        @class.methods[@method_name].funcs[@func_name].options.last.set_option(@option_option_name, "'" + tok + "'")
        @option_option_name = nil
      elsif @is_func_option && !@func_option.nil?
        @func_class.option.set_option(@func_option, tok)
        @func_option = nil
      end
    end
  end

  def on_ident(tok, f)
    if tok == 't'
      @is_option_type = true
    elsif @is_option_type
      if tok == 'timestamps'
        @class.methods[@method_name].funcs[@func_name].add_option(tok)
        @is_option_type = false
        @is_option = false
      else
        @option_type = tok
        @is_option = true
      end
      @is_option_type = false
    elsif @is_option
      if !@option_type.nil?
        @class.methods[@method_name].funcs[@func_name].add_option(@option_type, tok)
        @option_name = tok
        @is_option_option = true
        @option_type = nil
      elsif @option_option_name.nil?
        @option_option_name = tok
        @is_option_option = true
      end
    elsif @is_func_option
      if @func_option.nil?
        @func_option = tok
      else
        @func_class.option.set_option(@func_option, tok)
        @func_option = nil
      end
    elsif !@method_name.nil? && MigrationDefs::FuncName.has_key?(tok)
      @func_type = tok
      @is_func = true
    elsif @is_func
      if !@func_type.nil?
        @func_class = @class.methods[@method_name].add_func(@func_type, tok)
        @is_func_option = true
        @func_name = tok
        @func_type = nil
      end
      @is_func = false
    elsif MigrationDefs::MethodName.include?(tok)
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
    end
    @is_func_option = false
    @is_option = false
    @is_option_option = false
  end
  
  def on_do_block(tok, f)
    @is_do = true
  end
  
  def on_lbrase(tok, f)
    @is_do = true
  end
  
  def on_rbrase(tok, f)
    @is_do = false
  end
  
  def on_comma(tok, f)
    @on_comma = true
  end
  
  def on_tstring_content(tok, f)
    if @is_option_option && !@option_option_name.nil?
      @class.methods[@method_name].funcs[@func_name].options.last.set_option(@option_option_name, "'" + tok + "'")
      @option_option_name = nil
    elsif @is_func_option && !@func_option.nil?
      @func_class.option.set_option(@func_option, "'" + tok + "'")
      @func_option = nil
    end
  end
  
  def on_int(tok, f)
    if @is_option_option && !@option_option_name.nil?
      @class.methods[@method_name].funcs[@func_name].options.last.set_option(@option_option_name, tok)
      @option_option_name = nil
    elsif @is_func_option && !@func_option.nil?
      @func_class.option.set_option(@func_option, tok)
      @func_option = nil
    end
  end
end
