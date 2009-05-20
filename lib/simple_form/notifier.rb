# This is the class responsable to send the e-mails.
#
class SimpleForm
  class Notifier < ActionMailer::Base

    def contact(form)
      @from       = get_from_class_and_eval(form, :form_sender)
      @subject    = get_from_class_and_eval(form, :form_subject)
      @recipients = get_from_class_and_eval(form, :form_recipients)

      raise ScriptError, "You forgot to setup #{form.class.name} recipients" if @recipients.blank?
      raise ScriptError, "You set :append values but forgot to give me the request object" if form.request.nil? && !form.class.form_appendable.blank?

      @body['form']    = form
      @body['subject'] = @subject

      @sent_on = Time.now.utc
      @headers = form.class.form_headers
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
end
