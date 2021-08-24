module MailForm
  class Notifier < ActionMailer::Base
    self.mailer_name = "mail_form"
    append_view_path File.expand_path('../views', __FILE__)

    def contact(resource)
      if resource.request.nil? && resource.class.mail_appendable.any?
        raise ScriptError, "You set :append values but forgot to give me the request object"
      end

      @resource = @form = resource

      resource.class.mail_attachments.each do |attribute|
        value = resource.send(attribute)
        handle_multiple_attachments value
        add_attachment value
      end

      headers = resource.headers
      headers[:from]    ||= resource.email
      headers[:subject] ||= resource.class.model_name.human
      mail(headers)
    end

    private 
      def add_attachment(attch)
        return unless attch.respond_to?(:read)
        attachments[attch.original_filename] = attch.read
      end

      def handle_multiple_attachments(attchs) 
        return unless attchs.respond_to?('each')
        attchs.each do |attch|
          add_attachment attch
        end
      end
  end
end
