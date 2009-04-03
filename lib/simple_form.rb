dir = File.dirname(__FILE__)
require File.join(dir, 'simple_form', 'base')
require File.join(dir, 'simple_form', 'dsl')
require File.join(dir, 'simple_form', 'errors')
require File.join(dir, 'simple_form', 'notifier')

class SimpleForm
  extend SimpleForm::DSL

  ACCESSORS = [ :form_attributes, :form_validatable, :form_subject,
                :form_recipients, :form_sender, :form_captcha, :form_headers ]

  DEFAULT_MESSAGES = { :blank => "can't be blank", :invalid => "is invalid" }

  class_inheritable_reader *ACCESSORS
  protected *ACCESSORS

  # Configure default values
  #
  attribute :captcha => true
  attribute :validate => true

  headers({})
  recipients([])
  sender{|c| c.email }
  subject{|c| c.class.human_name }
end

SimpleForm::Notifier.template_root = File.join(dir, '..', 'views')
