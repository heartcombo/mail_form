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
      #   Whenever :validate is a symbol, the method given as symbol will be
      #   called. You can then add validations as you do in ActiveRecord (errors.add).
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
      #     attributes :type
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
      #   class ContactForm < SimpleForm
      #     append :remote_ip, :user_agent, :session, :cookies
      #   end
      #
      def append(*values)
        write_inheritable_array(:form_appendable, values)
      end

  end
end
