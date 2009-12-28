class MailForm < ActionMailer::Base
  autoload :Callbacks, 'mail_form/callbacks'
  autoload :Delivery,  'mail_form/delivery'
  autoload :Resource,  'mail_form/resource'
  autoload :Shim,      'mail_form/shim'

  self.template_root = File.expand_path('../views', File.dirname(__FILE__))

  def default(form)
    @from       = get_from_class_and_eval(form, :form_sender)
    @subject    = get_from_class_and_eval(form, :form_subject)
    @recipients = get_from_class_and_eval(form, :form_recipients)
    @template   = get_from_class_and_eval(form, :form_template)

    raise ScriptError, "You forgot to setup #{form.class.name} recipients" if @recipients.blank?
    raise ScriptError, "You set :append values but forgot to give me the request object" if form.request.nil? && !form.class.form_appendable.blank?

    @resource = @form = form
    @sent_on  = Time.now.utc
    @headers  = form.class.form_headers
    @content_type = 'text/html'

    form.class.form_attachments.each do |attribute|
      value = form.send(attribute)
      if value.respond_to?(:read)
        attachment value.content_type.to_s do |att|
          att.filename = value.original_filename
          att.body = value.read
        end
      end
    end
  end

  protected

  def get_from_class_and_eval(form, method)
    duck = form.class.send(method)

    if duck.is_a?(Proc)
      duck.call(form)
    elsif duck.is_a?(Symbol)
      form.send(duck)
    else
      duck
    end
  end
end


I18n.load_path.unshift File.expand_path('mail_form/locales/en.yml', File.dirname(__FILE__))