# -*- coding: utf-8 -*-
# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'migration_defs'

class FuncFilterFactory
  def self.get(func, src)
    if func.is_a? MigrationDefs::CreateTableFunc
      return CreateTableFuncFilter.new(src, func)
    elsif func.is_a? MigrationDefs::RenameTableFunc
      return RenameTableFuncFilter.new(src, func)
    elsif func.is_a? MigrationDefs::DropTableFunc
      return DropTableFuncFilter.new(src, func)
    elsif func.is_a? MigrationDefs::AddColumnFunc
      return AddColumnFuncFilter.new(src, func)
    elsif func.is_a? MigrationDefs::RemoveColumnFunc
      return RemoveColumnFuncFilter.new(src, func)
    elsif func.is_a? MigrationDefs::RenameColumnFunc
      return RenameColumnFuncFilter.new(src, func)
    elsif func.is_a? MigrationDefs::ChangeColumnFunc
      return ChangeColumnFuncFilter.new(src, func)
    elsif func.is_a? MigrationDefs::ChangeColumnDefaultFunc
      return ChangeColumnDefaultFuncFilter.new(src, func)
    elsif func.is_a? 'add_index'
    elsif func.is_a? 'remove_index'
    elsif func.is_a? 'rename_index'
    elsif func.is_a? 'add_timestamps'
    elsif func.is_a? 'remove_timestamps'
    else
      return nil
    end
  end
end

class CreateTableFuncFilter < Ripper::Filter
  attr_accessor :fclass, :func_str, :func_option_str, :column_option_str

  def initialize(src, fclass)
    super src

    @fclass = fclass
    @func_str = ''
    @is_func_option = true
    @func_option_str = ''
    @is_do = false
    @is_column_option = false
    @column_option_str = Array.new
  end

  def add_tok(tok)
    if @is_column_option
      @column_option_str[-1] += tok
    elsif @is_func_option
      @func_option_str += tok
    elsif @is_func
      @func_str += tok
    end
  end

  def on_default(event, tok, f)
    add_tok tok
  end

  def on_kw(tok, f)
    if tok == 'end'
      if @is_do
        @is_do = false
      end
    elsif tok == 'true' || tok == 'false'
      if @is_column_option && !@column_option.nil?
        @fclass.columns.last.set_option(@column_option, "'" + tok + "'")
        @column_option = nil
      elsif @is_func_option && !@func_option.nil?
        @fclass.option.set_option(@func_option, tok)
        @func_option = nil
      end
    end
    add_tok tok
  end

  def on_ident(tok, f)
    if tok == 't'
      @is_column = true
    elsif @is_column
      if (tok != 'timestamps') && (tok != 'attachment')
        @column_type = tok
        @is_column_type = true
        @column_option_str << ''
      else
        @fclass.add_column(tok)
        @is_column_type = false
      end
      @is_column = false
    elsif @is_column_type
      if !@column_type.nil?
        @fclass.add_column(@column_type, tok)
        @is_column_type = false
        @is_column_option = true
        @column_type = nil
      elsif
        @column_type = tok
      end
    elsif @is_column_option
      @column_option = tok
    elsif @is_func_option
      @func_option = tok
    end
    add_tok tok
  end

  def on_nl(tok, f)
    @is_func_option = false
    @is_column = false
    @is_column_option = false
    add_tok tok
  end

  def on_do_block(tok, f)
    @is_do = true
    add_tok tok
  end

  def on_lbrase(tok, f)
    @is_do = true
    add_tok tok
  end

  def on_rbrase(tok, f)
    @is_do = false
    add_tok tok
  end

  def on_tstring_content(tok, f)
    if @is_column_option && !@column_option.nil?
      @fclass.columns.last.set_option(@column_option, "'" + tok + "'")
      @column_option = nil
    elsif @is_func_option && !@func_option.nil?
      @fclass.option.set_option(@func_option, "'" + tok + "'")
      @func_option = nil
    end
    @is_tstring_content = true
    add_tok tok
  end

  def on_tstring_beg(tok, f)
    @is_tstring_content = false
    add_tok tok
  end

  def on_tstring_end(tok, f)
    if !@is_tstring_content
      on_tstring_content("", f)
    end
    add_tok tok
  end

  def on_int(tok, f)
    if @is_column_option && !@column_option.nil?
      @fclass.columns.last.set_option(@column_option, tok)
      @column_option = nil
    elsif @is_func_option && !@func_option.nil?
      @fclass.option.set_option(@func_option, tok)
      @func_option = nil
    end
    add_tok tok
  end

  def on_float(tok, f)
    if @is_column_option && !@column_option.nil?
      @fclass.columns.last.set_option(@column_option, tok)
      @column_option = nil
    elsif @is_func_option && !@func_option.nil?
      @fclass.option.set_option(@func_option, tok)
      @func_option = nil
    end
    add_tok tok
  end

end

class RenameTableFuncFilter < CreateTableFuncFilter
  def on_ident(tok, f)
    if @is_func_option && @is_comma
      @fclass.add_new_name tok
      @is_func_option = false
      @is_comma = false
    end
    add_tok tok
  end

  def on_comma(tok, f)
    @is_comma = true
    add_tok tok
  end

end

class DropTableFuncFilter < CreateTableFuncFilter
end

class AddColumnFuncFilter < CreateTableFuncFilter
  def initialize(src, fclass)
    super src, fclass

    @is_func_name = true
    @is_table_name = false
    @is_column = false
    @is_column_type = false
    @column_option_str = ''
  end

  def add_tok(tok)
    if @is_column_option
      @column_option_str += tok
    elsif @is_func_option
      @func_option_str += tok
    elsif @is_func
      @func_str += tok
    end
  end

  def on_kw(tok, f)
    if tok == 'end'
      if @is_do
        @is_do = false
      end
    elsif tok == 'true' || tok == 'false'
      if @is_column_option && !@column_option.nil?
        @fclass.column.set_option(@column_option, "'" + tok + "'")
        @column_option = nil
      elsif @is_func_option && !@func_option.nil?
        @fclass.option.set_option(@func_option, tok)
        @func_option = nil
      end
    end
    add_tok tok
  end

  def on_ident(tok, f)
    if @is_func_name
      @is_func_name = false
      @is_table_name = true
    elsif @is_table_name
      @is_table_name = false
      @is_column = true
    elsif @is_column
      @column_name = tok
      @is_column = false
      @is_column_type = true
    elsif @is_column_type
      @fclass.add_column(tok, @column_name)
      @is_column_type = false
      @is_column_option = true
    elsif @is_column_option
      @column_option = tok
    end
    add_tok tok
  end

  def on_tstring_content(tok, f)
    if @is_column_option && !@column_option.nil?
      @fclass.column.set_option(@column_option, "'" + tok + "'")
      @column_option = nil
    elsif @is_func_option && !@func_option.nil?
      @fclass.option.set_option(@func_option, "'" + tok + "'")
      @func_option = nil
    end
    @is_tstring_content = true
    add_tok tok
  end

  def on_int(tok, f)
    if @is_column_option && !@column_option.nil?
      @fclass.column.set_option(@column_option, tok)
      @column_option = nil
    elsif @is_func_option && !@func_option.nil?
      @fclass.option.set_option(@func_option, tok)
      @func_option = nil
    end
    add_tok tok
  end

  def on_float(tok, f)
    if @is_column_option && !@column_option.nil?
      @fclass.column.set_option(@column_option, tok)
      @column_option = nil
    elsif @is_func_option && !@func_option.nil?
      @fclass.option.set_option(@func_option, tok)
      @func_option = nil
    end
    add_tok tok
  end

end

class RemoveColumnFuncFilter < RenameTableFuncFilter
  def on_ident(tok, f)
    if @is_func_option && @is_comma
      @fclass.add_column_name tok
      @is_func_option = false
      @is_comma = false
    end
    add_tok tok
  end

end

class RenameColumnFuncFilter < RenameTableFuncFilter
  def initialize(src, fclass)
    super src, fclass

    @is_new_column = false;
  end

  def on_ident(tok, f)
    if @is_func_option && @is_comma
      @fclass.add_column_name tok
      @is_func_option = false
      @is_comma = false
      @is_new_column = true;
    elsif @is_new_column && @is_comma
      @fclass.add_new_column_name tok
      @is_comma = false
      @is_new_column = false;
    end
    add_tok tok
  end
end

class ChangeColumnFuncFilter < AddColumnFuncFilter
end

class ChangeColumnDefaultFuncFilter < RenameTableFuncFilter
  def initialize(src, fclass)
    super src, fclass

    @is_default = false
  end

  def on_kw(tok, f)
    if tok == 'end'
      if @is_do
        @is_do = false
      end
    elsif tok == 'true' || tok == 'false'
      if @is_default && @is_comma
        @fclass.set_column_default tok
        @is_comma = false
        @is_default = false;
      end
    end
    add_tok tok
  end

  def on_ident(tok, f)
    if @is_func_option && @is_comma
      @fclass.add_column_name tok
      @is_func_option = false
      @is_comma = false
      @is_default = true;
    elsif @is_default && @is_comma
      @fclass.set_column_default tok
      @is_comma = false
      @is_default = false;
    end
    add_tok tok
  end

  def on_tstring_content(tok, f)
    if @is_default && @is_comma
      @fclass.set_column_default "'#{tok}'"
      @is_comma = false
      @is_default = false;
    end
    @is_tstring_content = true
    add_tok tok
  end

  def on_int(tok, f)
    if @is_default && @is_comma
      @fclass.set_column_default tok
      @is_comma = false
      @is_default = false;
    end
    add_tok tok
  end

  def on_float(tok, f)
    if @is_default && @is_comma
      @fclass.set_column_default tok
      @is_comma = false
      @is_default = false;
    end
    add_tok tok
  end

end
