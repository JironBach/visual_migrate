# -*- coding: utf-8 -*-
# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'func_filter'

class MethodFilter < Ripper::Filter
  attr_accessor :mclass, :method_str, :funcs_str, :func_filters
  
  def initialize(src, mclass)
    super src

    @method_str = ''
    @funcs_str = Array.new
    @mclass = mclass
    @func_filters = Array.new
    @is_method = false
    @is_func = false
    @is_do = false
  end
  
  def add_tok tok
    if @is_func
      @funcs_str[-1] += tok
    elsif @is_method
      @method_str += tok
    end
  end
  
  def on_default(event, tok, f)
    add_tok tok
  end

  def on_kw(tok, f)
    if tok == 'def'
      @is_method = true
      @is_func = false
    end
    
    if tok == 'end'
      if @is_do
        @is_do = false
        add_tok tok
      elsif @is_func
        @is_func = false
        add_tok tok
      elsif @is_method
        index = 0
        @mclass.funcs.each do |func|
          puts '-----' + func.inspect + '-----'
          @func_filters << FuncFilterFactory.get(func, @funcs_str[index])
          @func_filters.last.parse
          index += 1
        end
        @is_method = false
      end
      add_tok tok
    end
  end
  
  def on_ident(tok, f)
    if !@method_name.nil? && MigrationDefs::FuncName.has_key?(tok)
      @func_type = tok
      @is_func = true
      @funcs_str << ''
    elsif !@func_type.nil?
      @func_class = @mclass.add_func(@func_type, tok)
      @func_type = nil
    elsif MigrationDefs::MethodName.include?(tok)
      @method_name = tok
    end
    add_tok tok
  end

  def on_nl(tok, f)
    @is_func = false
    add_tok tok
  end
  
  def on_do_block(tok, f)
    if !@is_func
      @is_func = true
    elsif !@is_do
      @is_do = true
    end
    add_tok tok
  end
  
  def on_lbrase(tok, f)
    if !@is_func
      @is_func = true
    elsif !@is_do
      @is_do = true
    end
    add_tok tok
  end
  
  def on_rbrase(tok, f)
    if @is_do
      @is_do = false
    elsif @is_func
      @is_func = false
    end
    add_tok tok
  end
  
end
