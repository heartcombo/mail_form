class SimpleForm
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
  # In test and in production, it returns true if aall captcha field are blank,
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

  # To check if the form is valid, we run the validations.
  #
  # If the validation is true, we just check if the field is not blank. If it's
  # a regexp, we check if it is not blank AND if the Regexp matches.
  #
  # You can have totally custom validations by sending a symbol. Then the method
  # given as symbol will be called and then you cann hook your validations there.
  #
  def valid?
    return false unless errors.empty?

    form_validatable.each_pair do |field, validation|
      next unless validation

      if validation.is_a?(Symbol)
        send(validation)
      elsif send(field).blank?
        errors.add(field, :blank)
      elsif validation.is_a?(Regexp)
        errors.add(field, :invalid) unless send(field) =~ validation
      end
    end

    errors.empty?
  end

  def invalid?
    !valid?
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
      SimpleForm::Notifier.deliver_contact(self)
      return true
    else
      return false
    end
  end
  alias :save :deliver

  # Add a human attribute name interface on top of I18n. If email is received as
  # attribute, it will look for a translated name on:
  #
  #   simple_form:
  #     attributes:
  #       email: E-mail
  #
  def self.human_attribute_name(attribute, options={})
    I18n.translate("attributes.#{attribute}", options.merge(:default => attribute.to_s.humanize, :scope => [:simple_form]))
  end

  # Add a human name interface on top of I18n. If you have a model named
  # SimpleForm, it will search for the localized name on:
  #
  #   simple_form:
  #     models:
  #       contact_form: Contact form
  #
  def self.human_name(options={})
    underscored = self.name.demodulize.underscore
    I18n.translate("models.#{underscored}", options.merge(:default => underscored.humanize, :scope => [:simple_form]))
  end

  # Return the errors in this form. The object returned as the same API as the
  # ActiveRecord one.
  #
  def errors
    @errors ||= SimpleForm::Errors.new(self)
  end

end
