class MailForm < ActionMailer::Base
  autoload :Base,      'mail_form/base'
  autoload :Callbacks, 'mail_form/callbacks'
  autoload :Delivery,  'mail_form/delivery'
  autoload :Shim,      'mail_form/shim'

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
    headers[:from] ||= resource.email
    mail(headers)
  end
end