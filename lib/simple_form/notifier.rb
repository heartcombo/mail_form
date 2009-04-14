# This is the class responsable to send the e-mails.
#
class SimpleForm
  class Notifier < ActionMailer::Base
    def contact(form)
      @subject = form.class.form_subject
      @subject = @subject.call(form) if @subject.is_a?(Proc)

      @from    = form.class.form_sender
      @from    = @from.call(form)    if @from.is_a?(Proc)

      @recipients = form.class.form_recipients

      raise ScriptError, "You forgot to setup #{form.class.name} recipients" if @recipients.blank?

      @body['form']    = form
      @body['subject'] = @subject

      @sent_on = Time.now.utc
      @headers = form.class.form_headers
      @content_type = 'text/html'

      form.class.form_attributes.each do |attribute|
        value = form.send(attribute)
        if value.respond_to?(:read)
          attachment value.content_type do |att|
            att.filename = value.original_filename
            att.body = value.read
          end
        end
      end
    end
  end
end
