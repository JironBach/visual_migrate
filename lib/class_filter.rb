# -*- coding: utf-8 -*-
# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'ripper'
require 'migration_defs'
require 'method_filter'

class ClassFilter < Ripper::Filter
  attr_accessor :class, :class_str, :methods_str, :method_filters
  
  def initialize(src)
    super src
    
    @class_str = ''
    @methods_str = Array.new
    @method_filters = Array.new
    @methods = Array.new
    @is_class = false
    @is_method = false
  end
  
  def add_tok(tok)
    if @is_method
      @methods_str[-1] += tok
    elsif @is_class
      @class_str += tok
    end
  end
  
  def on_default(event, tok, f)
    add_tok(tok)
  end

  def on_kw(tok, f)
    if tok == 'class'
      @is_class = true
    elsif tok == 'def'
      @is_method = true
      @methods_str << ''
    elsif tok == 'do'
      @is_do = true
    end
    
    add_tok(tok)

    if tok == 'end'
      if @is_do
        @is_do = false
      elsif @is_func
        @is_func = false
      elsif @is_method
        @methods << @class.add_method(@method_name)
        @is_method = false
      elsif @is_class
        index = 0
        @methods_str.each do |m|
          @method_filters << MethodFilter.new(m, @methods[index])
          @method_filters.last.parse
          index += 1
        end
        @is_class = false
      end
    end
  end
  
  def on_ident(tok, f)
    if @is_method && MigrationDefs::MethodName.include?(tok)
      @method_name = tok
      @class.add_method(tok)
    end

    add_tok(tok)
  end
  
  def on_const(tok, f)
    if @is_ancestors
      @parent_name += '::' + tok
    elsif @is_super
      @parent_name = tok
    elsif @is_class
      @class_name = tok
    end

    add_tok(tok)
  end
  
  def on_op(tok, f)
    if @is_class
      if tok == '<'
        @is_super = true
      elsif @is_super && tok == '::'
        @is_ancestors = true
      end
    end

    add_tok(tok)
  end
  
  def on_nl(tok, f)
    if @is_class && !@class_name.nil?
      @class = MigrationDefs::MigrationClass.new(@class_name, @parent_name)
      @class_name = nil
      @is_ancestors = false
      @is_super = false
    end

    add_tok(tok)
  end
  
  def on_do_block(tok, f)
    @is_do = true
    add_tok(tok)
  end
  
  def on_lbrase(tok, f)
    @is_do = true
    add_tok(tok)
  end
  
  def on_rbrase(tok, f)
    @is_do = false
    add_tok(tok)
  end
  
end
