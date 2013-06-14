# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'ripper'

class VisualMigrateRipper < Ripper::Filter
  attr_reader :migrate_strings
  DefNames = Array.new(['change', 'up', 'down'])
  MethodNames = Array.new([
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
  
  def initialize(src)
    super src
    
    @module = Module.new
    @migrate_strings = Hash.new Hash.new
  end
  
  def add_migrate_str(str)
    if !@method_name.nil?
      @migrate_strings[@def_name][@method_name] += str
    elsif !@def_name.nil?
      if @migrate_strings[@def_name].is_a?(Hash)
        @migrate_strings[@def_name] = ''
      end
      @migrate_strings[@def_name] += str
    end
  end
  
  def on_default(event, tok, f)
    add_migrate_str tok
  end

  def on_kw(tok, f)
    if tok == 'class'
      @is_class = true
    elsif !@vm_class.nil? && tok == 'def'
      @is_def = true
    elsif tok == 'end'
      if @is_do
        @is_do = false
        add_migrate_str tok
      elsif @is_def
        @is_def = false
        @def_name = nil
      end
    else
      add_migrate_str tok
    end
   end

  def on_ident(tok, f)
    if @def_name.nil? && DefNames.include?(tok)
      @def_name = tok
    else
      if !@def_name.nil?
        @migrate_strings[@def_name] += tok
      end
    end
  end
  
  def on_const(tok, f)
    if @is_ancestors
      @super_name += '::' + tok
    elsif @is_super
      @super_name = tok
    elsif @is_class
      @class_name = tok
    end

    add_migrate_str tok
  end
  
  def on_op(tok, f)
    if tok == '<'
      @is_super = true
    elsif @is_super && tok == '::'
      @is_ancestors = true
    end

    add_migrate_str tok
  end
  
  def on_nl(tok, f)
    if !@is_def && @is_class
      @is_ancestors = false
      @is_super = false
      @is_class = false
    end

    add_migrate_str tok
  end
  
  def on_do_block(tok, f)
    @is_do = true

    add_migrate_str tok
  end
end
