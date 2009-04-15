class SimpleForm
  module DSL

    protected

      # Declare your form attributes. All attributes declared here will be appended
      # to the e-mail, except the ones captcha is true.
      #
      # == Options
      #
      # * <tt>:validate</tt> - When true, validates the attributes can't be blank.
      #   When a regexp is given, check if the attribute matches is not blank and
      #   then if it matches the regexp.
      #
      # * <tt>:attachment</tt> - When given, expects a file to be sent and attaches
      #   it to the e-mail. Don't forget to set your form to multitype.
      #
      # * <tt>:captcha</tt> - When true, validates the attributes must be blank
      #   This is a simple way to avoid spam
      #
      # == Examples
      #
      #   class ContactForm < SimpleForm
      #     attributes :name,  :validate => true
      #     attributes :email, :validate => /^([^@]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
      #     attributes :message
      #     attributes :file, :attachment => true
      #     attributes :nickname, :captcha => true
      #   end
      #
      def attribute(*accessors)
        options = accessors.extract_options!

        attr_accessor *accessors

        if options[:attachment]
          write_inheritable_array(:form_attachments, accessors)
        elsif options[:captcha]
          write_inheritable_array(:form_captcha, accessors)
        else
          write_inheritable_array(:form_attributes, accessors)
        end

        if options[:validate]
          validations = {}
          accessors.each{ |a| validations[a] = options[:validate] }

          write_inheritable_hash(:form_validatable, validations)
        end
      end
      alias :attributes :attribute

      # Declares the subject of the contact email. It can be a string or a proc.
      # As a proc, it receives a simple form instance. When not specified, it
      # defaults to the class human name.
      #
      # == Examples
      #
      #   class ContactForm < SimpleForm
      #     subject "My Contact Form"
      #   end
      #
      def subject(string=nil, &block)
        write_inheritable_attribute(:form_subject, string || block)
      end

      # Declares contact email sender. It can be a string or a proc.
      # As a proc, it receives a simple form instance. By default is:
      #
      #   sender{ |c| c.email }
      #
      # This requires that your SimpleForm object have at least an email attribute.
      #
      # == Examples
      #
      #   class ContactForm < SimpleForm
      #     # Change sender to include also the name
      #     sender{|c| %{"#{c.name}" <#{c.email}>} }
      #   end
      #
      def sender(string=nil, &block)
        write_inheritable_attribute(:form_sender, string || block)
      end
      alias :from :sender

      # Additional headers to your e-mail.
      #
      # == Examples
      #
      #   class ContactForm < SimpleForm
      #     headers { :content_type => 'text/html' }
      #   end
      #
      def headers(hash)
        write_inheritable_hash(:form_headers, hash)
      end

      # Who will receive the e-mail. Can be a string or array.
      #
      # == Examples
      #
      #   class ContactForm < SimpleForm
      #     recipients "jose.valim@gmail.com"
      #   end
      #
      def recipients(string_or_array_or_proc)
        write_inheritable_attribute(:form_recipients, string_or_array_or_proc)
      end
      alias :to :recipients

  end
end
