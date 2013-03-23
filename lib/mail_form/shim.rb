require 'active_model'

# This the module which makes any class behave like ActiveModel.
module MailForm
  module Shim
    def self.included(base)
      base.class_eval do
        extend ActiveModel::Naming
        extend ActiveModel::Translation
        extend ActiveModel::Callbacks
        include ActiveModel::Validations
        include ActiveModel::Conversion

        extend MailForm::Shim::ClassMethods
        define_model_callbacks :deliver
      end
    end

    module ClassMethods
      def i18n_scope
        :mail_form
      end
    end

    # Initialize assigning the parameters given as hash.
    def initialize(params={})
      params.each_pair do |attr, value|
        send("#{attr}=", value) if respond_to?("#{attr}=", true)
      end unless params.blank?
    end

    # Always return true so when using form_for, the default method will be post.
    def new_record?
      true
    end

    def persisted?
      false
    end

    # Always return nil so when using form_for, the default method will be post.
    def id
      nil
    end

    # Create just check validity, and if so, trigger callbacks.
    def deliver
      if valid?
        run_callbacks :deliver
      else
        false
      end
    end
    alias :save :deliver
  end
end
