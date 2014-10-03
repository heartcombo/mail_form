module MailForm
  module Delivery
    extend ActiveSupport::Concern

    included do
      class_attribute :mail_attributes
      self.mail_attributes = []

      class_attribute :mail_captcha
      self.mail_captcha = []

      class_attribute :mail_attachments
      self.mail_attachments = []

      class_attribute :mail_appendable
      self.mail_appendable = []

      if respond_to?(:before_deliver) && respond_to?(:after_deliver)
        before_deliver :not_spam?
        after_deliver  :deliver!
      else # For ActiveRecord compatibility
        before_create :not_spam?
        after_create  :deliver!
        alias :deliver :save
      end

      attr_accessor :request
    end

    module ClassMethods
      # Declare your form attributes. All attributes declared here will be appended
      # to the e-mail, except the ones captcha is true.
      #
      # == Options
      #
      # * :validate - A hook to validates_*_of. When true is given, validates the
      #       presence of the attribute. When a regexp, validates format. When array,
      #       validates the inclusion of the attribute in the array.
      #
      #       Whenever :validate is given, the presence is automatically checked. Give
      #       :allow_blank => true to override.
      #
      #       Finally, when :validate is a symbol, the method given as symbol will be
      #       called. Then you can add validations as you do in ActiveRecord (errors.add).
      #
      # * <tt>:attachment</tt> - When given, expects a file to be sent and attaches
      #   it to the e-mail. Don't forget to set your form to multitype.
      #
      # * <tt>:captcha</tt> - When true, validates the attributes must be blank
      #   This is a simple way to avoid spam
      #
      # == Examples
      #
      #   class ContactForm < MailForm
      #     attributes :name,  :validate => true
      #     attributes :email, :validate => /^([^@]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
      #     attributes :type,  :validate => ["General", "Interface bug"]
      #     attributes :message
      #     attributes :screenshot, :attachment => true, :validate => :interface_bug?
      #     attributes :nickname, :captcha => true
      #
      #     def interface_bug?
      #       if type == 'Interface bug' && screenshot.nil?
      #         self.errors.add(:screenshot, "can't be blank when you are reporting an interface bug")
      #       end
      #     end
      #   end
      #
      def attribute(*accessors)
        options = accessors.extract_options!

        # TODO: make this not depend on column_names
        columns_methods = self.respond_to?(:column_names) ? column_names.map(&:to_sym) : []
        attr_accessor(*(accessors - instance_methods.map(&:to_sym) - columns_methods))

        if options[:attachment]
          self.mail_attachments += accessors
        elsif options[:captcha]
          self.mail_captcha += accessors
        else
          self.mail_attributes += accessors
        end

        validation = options.delete(:validate)
        return unless validation

        accessors.each do |accessor|
          case validation
          when Symbol, Class
            validate validation
            break
          when Regexp
            validates_format_of accessor, :with => validation, :allow_blank => true
          when Array
            validates_inclusion_of accessor, :in => validation, :allow_blank => true
          when Range
            validates_length_of accessor, :within => validation, :allow_blank => true
          end

          validates_presence_of accessor unless options[:allow_blank] == true
        end
      end
      alias :attributes :attribute

      # Values from request object to be appended to the contact form.
      # Whenever used, you have to send the request object when initializing the object:
      #
      #   @contact_form = ContactForm.new(params[:contact_form], request)
      #
      # You can get the values to be appended from the AbstractRequest
      # documentation (http://api.rubyonrails.org/classes/ActionController/AbstractRequest.html)
      #
      # == Examples
      #
      #   class ContactForm < MailForm
      #     append :remote_ip, :user_agent, :session, :cookies
      #   end
      #
      def append(*values)
        self.mail_appendable += values
      end
    end

    # In development, raises an error if the captcha field is not blank. This is
    # is good to remember that the field should be hidden with CSS and shown only
    # to robots.
    #
    # In test and in production, it returns true if all captcha fields are blank,
    # returns false otherwise.
    #
    def spam?
      self.class.mail_captcha.each do |field|
        next if send(field).blank?

        if defined?(Rails) && Rails.env.development?
          raise ScriptError, "The captcha field #{field} was supposed to be blank"
        else
          return true
        end
      end

      false
    end

    def not_spam?
      !spam?
    end

    # Deliver the resource without running any validation.
    def deliver!
      mailer = MailForm::Notifier.contact(self)
      if mailer.respond_to?(:deliver_now)
        mailer.deliver_now
      else
        mailer.deliver
      end
    end

    # Returns a hash of attributes, according to the attributes existent in
    # self.class.mail_attributes.
    def mail_form_attributes
      self.class.mail_attributes.each_with_object({}) do |attr, hash|
        hash[attr.to_s] = send(attr)
      end
    end
  end
end
