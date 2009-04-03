class SimpleForm

  # Initialize assigning the parameters given as hash (just as in ActiveRecord).
  #
  def initialize(params={})
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

  # The form is valid if all elements marked to be validated are not blank
  # and elements given with a regexp match the regexp.
  #
  def valid?
    return false unless errors.empty?

    form_validatable.each_pair do |field, validation|
      if send(field).blank?
        errors.add(field, :blank)
        next
      end

      errors.add(field, :invalid) if validation.is_a?(Regexp) && send(field) !~ validation
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
  def deliver
    if self.not_spam? && self.valid?
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
