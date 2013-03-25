module MailForm
  class Notifier < ActionMailer::Base
    # since ActionMailer 3.0 has own simple_format method
    # but we need one from the ActionPack
    # https://github.com/rails/rails/commit/fb34f8577c47d958ca32b7ab585c1904e1a776b1
    helper do
      def simple_format(text, html_options={}, options={})
        @text_helper ||= Class.new do
          include ActionView::Helpers::TextHelper
          include ActionView::Helpers::TagHelper
          include ActionView::Helpers::SanitizeHelper
        end.new

        @text_helper.simple_format(text, html_options, options)
      end
    end

    self.mailer_name = "mail_form"
    append_view_path File.expand_path('../views', __FILE__)

    def contact(resource)
      if resource.request.nil? && resource.class.mail_appendable.any?
        raise ScriptError, "You set :append values but forgot to give me the request object"
      end

      @resource = @form = resource

      resource.class.mail_attachments.each do |attribute|
        value = resource.send(attribute)
        next unless value.respond_to?(:read)
        attachments[value.original_filename] = value.read
      end

      headers = resource.headers
      headers[:from]    ||= resource.email
      headers[:subject] ||= resource.class.model_name.human
      mail(headers)
    end
  end
end
