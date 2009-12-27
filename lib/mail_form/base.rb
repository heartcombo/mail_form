class MailForm
  extend ActiveModel::Naming
  extend ActiveModel::Translation
  include ActiveModel::Validations
  include ActiveModel::Conversion

  attr_accessor :request

  # Initialize assigning the parameters given as hash (just as in ActiveRecord).
  #
  # It also accepts the request object as second parameter which must be sent
  # whenever :append is called.
  #
  def initialize(params={}, request=nil)
    @request = request
    params.each_pair do |attr, value|
      self.send(:"#{attr}=", value)
    end unless params.blank?
  end

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

  # Always return true so when using form_for, the default method will be post.
  #
  def new_record?
    true
  end

  # Always return nil so when using form_for, the default method will be post.
  #
  def id
    nil
  end

  # If is not spam and the form is valid, we send the e-mail and returns true.
  # Otherwise returns false.
  #
  def deliver(run_validations=true)
    if !run_validations || (self.not_spam? && self.valid?)
      MailForm::Notifier.deliver_contact(self)
      return true
    else
      return false
    end
  end
  alias :save :deliver

  def self.i18n_scope
    :mail_form
  end

  def self.lookup_ancestors
    super - [MailForm]
  end

end
