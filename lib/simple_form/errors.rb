# Provides an Errors class similar with ActiveRecord ones.
#
#   class ContactForm < SimpleForm
#     attributes :name,  :validate => true
#     attributes :email, :validate => /^([^@]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
#     attributes :message
#     attributes :nickname, :captcha => true
#   end
#
# When validating an attribute name as above, it will search for messages in
# the following order:
#
#   simple_form.messages.name
#   simple_form.messages.blank
#
# When validating email, it will search for:
#
#   simple_form.messages.name
#   simple_form.messages.invalid
#
# If the message is not available, it will output: "can't be blank" in the first
# case and "is invalid" in the second.
#
class SimpleForm
  class Errors < Hash

    def initialize(base, *args)
      @base = base
      super(*args)
    end

    alias :add   :store
    alias :count :size

    def on(attribute)
      attribute = attribute.to_sym
      return nil unless self[attribute]

      generate_message_for(attribute, self[attribute])
    end

    def full_messages
      map do |attribute, message|
        next if message.nil?
        attribute = attribute.to_sym
        "#{@base.class.human_attribute_name(attribute)} #{generate_message_for(attribute, message)}"
      end.compact.reverse
    end

    protected

      def generate_message_for(attribute, message)
        I18n.t(attribute, :default => [ message, DEFAULT_MESSAGES[message] ], :scope => [:simple_form, :messages])
      end

  end
end
