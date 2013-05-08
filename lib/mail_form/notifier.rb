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