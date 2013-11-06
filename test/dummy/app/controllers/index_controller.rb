class IndexController < ApplicationController
  def index
    @tables = ActiveRecord::Base.connection.tables
    if !params[:id].nil?
      @columns = Kernel.const_get(params[:id].singularize.camelize).column_names
    end
    render :index
  end
end
