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
        if value.is_a?(Array)
          value.each { |attachment_file| add_attachment(attachment_file) }
        else
          add_attachment(value)
        end
      end

      headers = resource.headers
      headers[:from]    ||= resource.email
      headers[:subject] ||= resource.class.model_name.human
      mail(headers)
    end

    private

      def add_attachment(attachment_file)
        return unless attachment_file.respond_to?(:read)
        attachments[attachment_file.original_filename] = attachment_file.read
      end
  end
end
