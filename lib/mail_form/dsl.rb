class MailForm
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
      #   class ContactForm < MailForm
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

      # Declares contact email sender. It can be a string or a proc or a symbol.
      #
      # When a symbol is given, it will call a method on the form object with
      # the same name as the symbol. As a proc, it receives a simple form
      # instance. By default is the class human name.
      #
      # == Examples
      #
      #   class ContactForm < MailForm
      #     subject "My Contact Form"
      #   end
      #
      def subject(duck=nil, &block)
        write_inheritable_attribute(:form_subject, duck || block)
      end

      # Declares contact email sender. It can be a string or a proc or a symbol.
      #
      # When a symbol is given, it will call a method on the form object with
      # the same name as the symbol. As a proc, it receives a simple form
      # instance. By default is:
      #
      #   sender{ |c| c.email }
      #
      # This requires that your MailForm object have an email attribute.
      #
      # == Examples
      #
      #   class ContactForm < MailForm
      #     # Change sender to include also the name
      #     sender { |c| %{"#{c.name}" <#{c.email}>} }
      #   end
      #
      def sender(duck=nil, &block)
        write_inheritable_attribute(:form_sender, duck || block)
      end
      alias :from :sender

      # Who will receive the e-mail. Can be a string or array or a symbol or a proc.
      #
      # When a symbol is given, it will call a method on the form object with
      # the same name as the symbol. As a proc, it receives a simple form instance.
      #
      # Both the proc and the symbol must return a string or an array. By default
      # is nil.
      #
      # == Examples
      #
      #   class ContactForm < MailForm
      #     recipients [ "first.manager@domain.com", "second.manager@domain.com" ]
      #   end
      #
      def recipients(duck=nil, &block)
        write_inheritable_attribute(:form_recipients, duck || block)
      end
      alias :to :recipients

      # Additional headers to your e-mail.
      #
      # == Examples
      #
      #   class ContactForm < MailForm
      #     headers { :content_type => 'text/html' }
      #   end
      #
      def headers(hash)
        write_inheritable_hash(:form_headers, hash)
      end

      # Customized template for your e-mail, if you don't want to use default
      # 'contact' template or need more than one contact form with different
      # template layouts.
      #
      # When a symbol is given, it will call a method on the form object with
      # the same name as the symbol. As a proc, it receives a simple form
      # instance. Both method and proc must return a string with the template
      # name. Defaults to 'contact'.
      #
      # == Examples
      #
      #   class ContactForm < MailForm
      #     # look for a template in views/mail_form/notifier/my_template.erb
      #     template 'my_template'
      #   end
      #
      def template(new_template)
        write_inheritable_attribute(:form_template, new_template)
      end

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
        write_inheritable_array(:form_appendable, values)
      end

  end
end
