module VisualMigrate
  module ApplicationHelper
    def nl2br(str)
      str.gsub(/\r\n|\r|\n/, "<br />")
    end
end
end
