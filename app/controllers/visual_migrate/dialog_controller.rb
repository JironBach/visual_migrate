require_dependency "visual_migrate/application_controller"

module VisualMigrate
  class DialogController < ApplicationController
    def add_new_func
      render :add_new_func
    end
  end
end
