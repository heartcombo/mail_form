class MailForm < ActionMailer::Base
  autoload :Base,      'mail_form/base'
  autoload :Callbacks, 'mail_form/callbacks'
  autoload :Delivery,  'mail_form/delivery'
  autoload :Shim,      'mail_form/shim'

  self.template_root = File.expand_path('../views', File.dirname(__FILE__))

  def default(resource)
    @from       = get_from_class_and_eval(resource, :mail_sender)
    @subject    = get_from_class_and_eval(resource, :mail_subject)
    @recipients = get_from_class_and_eval(resource, :mail_recipients)
    @template   = get_from_class_and_eval(resource, :mail_template)

    if @recipients.blank?
      raise ScriptError, "You forgot to setup #{resource.class.name} recipients"
    end

    if resource.request.nil? && resource.class.mail_appendable.present?
      raise ScriptError, "You set :append values but forgot to give me the request object"
    end

    @resource = @form = resource
    @sent_on  = Time.now.utc
    @headers  = resource.class.mail_headers
    @content_type = 'text/html'

    resource.class.mail_attachments.each do |attribute|
      value = resource.send(attribute)
      next unless value.respond_to?(:read)

      attachment value.content_type.to_s do |att|
        att.filename = value.original_filename
        att.body = value.read
      end
    end
  end

  protected

  def get_from_class_and_eval(resource, method)
    duck = resource.class.send(method)

    if duck.is_a?(Proc)
      duck.call(resource)
    elsif duck.is_a?(Symbol)
      resource.send(duck)
    else
      duck
    end
  end
end