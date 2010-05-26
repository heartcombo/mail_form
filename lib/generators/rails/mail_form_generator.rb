module Rails
  module Generators
    class MailFormGenerator < Rails::Generators::NamedBase
      def self.source_root
        @_mail_form_source_root ||= File.expand_path("../templates", __FILE__)
      end

      argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"

      check_class_collision

      def create_model_file
        template 'model.rb', File.join('app/models', class_path, "#{file_name}.rb")
      end
    end
  end
end