# coding: utf-8

require 'test_helper'

class MailFormBaseTest < ActiveSupport::TestCase

  def setup
    ActionMailer::Base.deliveries = []
  end

  def test_id_is_nil
    assert_equal nil, ContactForm.new.id
  end

  def test_is_always_a_new_record
    assert ContactForm.new.new_record?
  end

  def test_initialize_with_options
    form = ContactForm.new(:name => 'José', :email => 'jose@my.email.com')
    assert_equal 'José', form.name
    assert_equal 'jose@my.email.com', form.email
  end

  def test_spam_is_true_when_captcha_field_is_set
    form = ContactForm.new(:nickname => 'not_blank')
    assert form.spam?
    assert !form.not_spam?
  end

  def test_spam_is_false_when_captcha_field_is_not_set
    form = ContactForm.new
    assert !form.spam?
    assert form.not_spam?
  end

  def test_is_not_valid_when_validatable_attributes_are_blank
    form = ContactForm.new
    assert !form.valid?
    assert form.invalid?

    assert_equal 2, form.errors.count
    assert_equal ["can't be blank"], form.errors[:email]
    assert_equal ["can't be blank"], form.errors[:name]
  end

  def test_is_not_valid_when_validatable_regexp_does_not_match
    form = ContactForm.new(:name => 'Jose', :email => 'not_valid')
    assert !form.valid?
    assert form.invalid?

    assert_equal(1, form.errors.count)
    assert_equal ["is invalid"], form.errors[:email]
  end

  def test_is_valid_when_validatable_attributes_are_valid
    form = ContactForm.new(:name => 'Jose', :email => 'is.valid@email.com')
    assert form.valid?
    assert !form.invalid?
  end

  def test_symbols_given_to_validate_are_called
    form = ContactForm.new
    assert !form.callback_run?
    form.valid?
    assert form.callback_run?
  end

  def test_deliver_is_false_when_is_a_spam
    form = ContactForm.new(:name => 'Jose', :email => 'is.valid@email.com', :nickname => 'not_blank')
    assert form.valid?
    assert form.spam?
    assert !form.deliver
  end

  def test_deliver_is_false_when_is_invalid
    form = ContactForm.new(:name => 'Jose', :email => 'is.com')
    assert form.invalid?
    assert form.not_spam?
    assert !form.deliver
  end

  def test_deliver_is_true_when_is_not_spam_and_valid
    form = ContactForm.new(:name => 'Jose', :email => 'is.valid@email.com')
    assert form.valid?
    assert form.not_spam?
    assert form.deliver
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  def test_human_name_returns_a_humanized_name
    assert_equal 'Contact form', ContactForm.model_name.human
  end

  def test_human_name_can_be_localized
    I18n.backend.store_translations(:en, :mail_form => { :models => { :contact_form => 'Formulário de contato' } })
    assert_equal 'Formulário de contato', ContactForm.model_name.human
  end

  def test_human_attribute_name_returns_a_humanized_attribute
    assert_equal 'Message', ContactForm.human_attribute_name(:message)
  end

  def test_human_attribute_name_can_be_localized
    I18n.backend.store_translations(:en, :mail_form => { :attributes => { :contact_form => { :message => 'Mensagem' } } })
    assert_equal 'Mensagem', ContactForm.human_attribute_name(:message)
  end

  def test_activemodel_linked_errors
    form = ContactForm.new(:email => 'not_valid', :category => "invalid")
    form.valid?
    assert_equal ["can't be blank"],              form.errors[:name]
    assert_equal ["is invalid"],                  form.errors[:email]
    assert_equal ["is not included in the list"], form.errors[:category]
    assert_equal [],                              form.errors[:message]
  end

  def test_activemodel_errors_lookups_model_keys
    I18n.backend.store_translations(:en, :mail_form => { :errors => { :models => { :contact_form =>
      { :attributes => { :email => { :invalid => 'fill in the email' },
                         :name => { :blank => 'fill in the name' } }
      }
    }}})

    form = ContactForm.new(:email => 'not_valid')
    form.valid?

    assert_equal ["fill in the name"],  form.errors[:name]
    assert_equal ["fill in the email"], form.errors[:email]
  end

  def teardown
    I18n.reload!
  end

end
