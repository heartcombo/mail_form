require 'active_model'
require 'mail_form/base'
require 'mail_form/dsl'
require 'mail_form/notifier'

class MailForm
  extend MailForm::DSL

  ACCESSORS = [ :form_attributes, :form_validatable, :form_subject,
                :form_attachments, :form_recipients, :form_sender,
                :form_captcha, :form_headers, :form_template, :form_appendable ]

  DEFAULT_MESSAGES = { :blank => "can't be blank", :invalid => "is invalid" }

  class_inheritable_reader *ACCESSORS
  protected *ACCESSORS

  # Initialize arrays and hashes
  #
  write_inheritable_array :form_captcha, []
  write_inheritable_array :form_appendable, []
  write_inheritable_array :form_attributes, []
  write_inheritable_array :form_attachments, []
  write_inheritable_hash  :form_validatable, {}

  headers({})
  sender {|c| c.email }
  subject{|c| c.class.model_name.human }
  template 'default'
end

I18n.load_path.unshift File.expand_path('mail_form/locales/en.yml', File.dirname(__FILE__))
MailForm::Notifier.template_root = File.expand_path('../views', File.dirname(__FILE__))
