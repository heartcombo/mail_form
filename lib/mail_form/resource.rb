class MailForm::Resource
  include MailForm::Shim
  extend  MailForm::DSL

  ACCESSORS = [ :form_attributes, :form_subject, :form_captcha,
                :form_attachments, :form_recipients, :form_sender,
                :form_headers, :form_template, :form_appendable ]

  class_inheritable_reader *ACCESSORS
  protected *ACCESSORS

  before_create :not_spam?
  after_create  :deliver!

  # Initialize arrays and hashes
  write_inheritable_array :form_captcha, []
  write_inheritable_array :form_appendable, []
  write_inheritable_array :form_attributes, []
  write_inheritable_array :form_attachments, []

  headers({})
  sender {|c| c.email }
  subject{|c| c.class.model_name.human }
  template 'default'

  attr_accessor :request

  # In development, raises an error if the captcha field is not blank. This is
  # is good to remember that the field should be hidden with CSS and shown only
  # to robots.
  #
  # In test and in production, it returns true if all captcha fields are blank,
  # returns false otherwise.
  #
  def spam?
    form_captcha.each do |field|
      next if send(field).blank?

      if RAILS_ENV == 'development'
        raise ScriptError, "The captcha field #{field} was supposed to be blank"
      else
        return true
      end
    end

    return false
  end

  def not_spam?
    !spam?
  end

  # Deliver the resource checking if it's valid? and not_spam?
  def deliver
    create
  end

  # Deliver the resource without checking any condition.
  def deliver!
    MailForm.deliver_default(self)
  end
end
