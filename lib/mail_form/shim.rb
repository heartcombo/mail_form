require 'active_model'

# This the module which makes any class behave like ActiveModel.
module MailForm::Shim
  def self.included(base)
    base.class_eval do
      extend ActiveModel::Naming
      extend ActiveModel::Translation

      include ActiveModel::Validations
      include ActiveModel::Conversion

      extend MailForm::Callbacks
      extend MailForm::Shim::ClassMethods
    end
  end

  module ClassMethods
    def i18n_scope
      :mail_form
    end
  end

  # Initialize assigning the parameters given as hash (just as in ActiveRecord).
  def initialize(params={})
    params.each_pair do |attr, value|
      self.send(:"#{attr}=", value)
    end unless params.blank?
  end

  # Always return true so when using form_for, the default method will be post.
  def new_record?
    true
  end

  # Always return nil so when using form_for, the default method will be post.
  def id
    nil
  end

  # Create just check validity, and if so, trigger callbacks.
  def create
    if valid?
      _run_create_callbacks { true }
    else
      false
    end
  end
  alias :save :create
end