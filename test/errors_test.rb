require File.dirname(__FILE__) + '/test_helper'

class SimpleFormErrorsTest < ActiveSupport::TestCase

  def test_errors_respond_to_some_hash_methods
    assert ContactForm.new.errors.respond_to?(:each)
    assert ContactForm.new.errors.respond_to?(:each_pair)
    assert ContactForm.new.errors.respond_to?(:size)
  end

  def test_count_is_an_alias_to_size
    errors = ContactForm.new.errors
    assert_equal errors.size, errors.count
  end

  def test_on_returns_the_message_in_the_given_attribute
    form = ContactForm.new(:email => 'not_valid')
    form.valid?
    assert_equal "can't be blank", form.errors.on(:name)
    assert_equal "is invalid",     form.errors.on(:email)
    assert_equal nil,              form.errors.on(:message)
  end

  def test_on_returns_a_default_localized_message_in_the_given_attribute
    I18n.backend.store_translations(:en, :simple_form => { :messages => { :invalid => 'is not valid', :blank => 'should be filled' } })

    form = ContactForm.new(:email => 'not_valid')
    form.valid?

    assert_equal "should be filled", form.errors.on(:name)
    assert_equal "is not valid",     form.errors.on(:email)
    assert_equal nil,                form.errors.on(:message)
  end

  def test_on_returns_an_attribute_localized_message_in_the_given_attribute
    I18n.backend.store_translations(:en, :simple_form => { :messages => { :email => 'fill in the email', :name => 'fill in the name' } })

    form = ContactForm.new(:email => 'not_valid')
    form.valid?

    assert_equal "fill in the name",  form.errors.on(:name)
    assert_equal "fill in the email", form.errors.on(:email)
    assert_equal nil,                 form.errors.on(:message)
  end

  def test_full_messages
    form = ContactForm.new(:email => 'not_valid')
    form.valid?

    assert form.errors.full_messages.include?("Name can't be blank")
    assert form.errors.full_messages.include?("Email is invalid")
  end

  def test_full_localized_messages
    I18n.backend.store_translations(:en, :simple_form => { :messages => { :email => 'is not valid', :blank => 'should be filled' }, :attributes => { :email => 'E-mail' } })

    form = ContactForm.new(:email => 'not_valid')
    form.valid?

    assert form.errors.full_messages.include?("Name should be filled")
    assert form.errors.full_messages.include?("E-mail is not valid")
  end

  def teardown
    I18n.reload!
  end
end
