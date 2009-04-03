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
    end
  end
end
