# -*- coding: utf-8 -*-
# To change this template, choose Tools | Templates
# and open the template in the editor.

class FuncFilter < Ripper::Filter
  attr_accessor :fclass, :func_str, :option_str
  
  def initialize(src, fclass)
    super src
    
    @fclass = fclass
    @func_str = ''
    @option_str = Array.new
    @is_do = false
    @is_option = false
    @is_option_option = false
  end

  def add_tok(tok)
    if @is_option
      @option_str[-1] += tok
    elsif @is_func
      @func_str += tok
    end
  end
  
  def on_default(event, tok, f)
    add_tok(tok)
  end

  def on_kw(tok, f)
    if tok == 'end'
      if @is_do
        @is_do = false
      end
    elsif tok == 'true' || tok == 'false'
      if @is_option_option && !@option_option_name.nil?
        @fclass.columns.last.set_option(@option_option_name, "'" + tok + "'")
        @option_option_name = nil
      elsif @is_func_option && !@func_option.nil?
        @fclass.option.set_option(@func_option, tok)
        @func_option = nil
      end
    end

    add_tok(tok)
  end
  
  def on_ident(tok, f)
    if tok == 't'
      @is_option_type = true
    elsif @is_option_type
      Rails.logger.debug 'is_option_type!'
      if tok == 'timestamps'
        @fclass.add_column(tok)
        @is_option = false
      else
        @option_type = tok
        @is_option = true
        @option_str << ''
      end
      @is_option_type = false
    elsif @is_option
      Rails.logger.debug 'is_option!'
      if !@option_type.nil?
        @fclass.add_column(@option_type, tok)
        @option_name = tok
        @is_option_option = true
        @option_type = nil
      elsif @option_option_name.nil?
        @option_option_name = tok
        @is_option_option = true
      end
    elsif @is_func_option
      Rails.logger.debug 'is_func_option!'
      if @func_option.nil?
        @func_option = tok
      else
        @fclass.option.set_option(@func_option, tok)
        @func_option = nil
      end
    end

    add_tok(tok)
  end
  
  def on_nl(tok, f)
    @is_func_option = false
    @is_option = false
    @is_option_option = false
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
  
  def on_tstring_content(tok, f)
    if @is_option_option && !@option_option_name.nil?
      @fclass.columns.last.set_option(@option_option_name, "'" + tok + "'")
      @option_option_name = nil
    elsif @is_func_option && !@func_option.nil?
      @fclass.option.set_option(@func_option, "'" + tok + "'")
      @func_option = nil
    end
    add_tok(tok)
  end
  
  def on_int(tok, f)
    if @is_option_option && !@option_option_name.nil?
      @fclass.columns.last.set_option(@option_option_name, tok)
      @option_option_name = nil
    elsif @is_func_option && !@func_option.nil?
      @fclass.option.set_option(@func_option, tok)
      @func_option = nil
    end
    add_tok(tok)
  end

end
