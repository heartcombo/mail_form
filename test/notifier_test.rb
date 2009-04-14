require File.dirname(__FILE__) + '/test_helper'

class SimpleFormNotifierTest < ActiveSupport::TestCase

  def setup
    @form     = ContactForm.new(:name => 'José', :email => 'my.email@my.domain.com', :message => 'Cool')
    @advanced = AdvancedForm.new(:name => 'José', :email => 'my.email@my.domain.com', :message => "Cool\nno?")
    test_file = ActionController::TestUploadedFile.new(File.join(File.dirname(__FILE__), 'test-file.txt'))
    @with_file = FileForm.new(:name => 'José', :email => 'my.email@my.domain.com', :message => "Cool\nno?", :file => test_file)
    ActionMailer::Base.deliveries = []
  end

  def test_email_is_sent
    @form.deliver
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  def test_subject_defaults_to_class_human_name
    @form.deliver
    assert_equal 'Contact form', ActionMailer::Base.deliveries.first.subject
  end

  def test_subject_is_a_string
    @advanced.deliver
    assert_equal 'My Advanced Form', ActionMailer::Base.deliveries.first.subject
  end

  def test_sender_defaults_to_form_email
    @form.deliver
    assert_equal ['my.email@my.domain.com'], ActionMailer::Base.deliveries.first.from
  end

  def test_error_is_raised_when_recipients_is_nil
    assert_raise ScriptError do
      NullRecipient.new.deliver
    end
  end

  def test_recipients_is_a_string
    @form.deliver
    assert_equal ['my.email@my.domain.com'], ActionMailer::Base.deliveries.first.to
  end

  def test_recipients_is_an_array
    @advanced.deliver
    assert_equal ['my.email@my.domain.com', 'my.first@email.com', 'my.second@email.com'], ActionMailer::Base.deliveries.first.to
  end

  def test_headers_is_a_hash
    @advanced.deliver
    assert_equal '<mypath>', ActionMailer::Base.deliveries.first.header['return-path'].to_s
  end

  def test_body_contains_subject
    @form.deliver
    assert_match /Contact form/, ActionMailer::Base.deliveries.first.body
  end

  def test_body_contains_attributes_values
    @form.deliver
    assert_match /José/, ActionMailer::Base.deliveries.first.body
    assert_match /my.email@my.domain.com/, ActionMailer::Base.deliveries.first.body
    assert_match /Cool/, ActionMailer::Base.deliveries.first.body
  end

  def test_body_contains_attributes_names
    @form.deliver
    assert_match /Name:/, ActionMailer::Base.deliveries.first.body
    assert_match /Email:/, ActionMailer::Base.deliveries.first.body
    assert_match /Message:/, ActionMailer::Base.deliveries.first.body
  end

  def test_body_contains_localized_attributes_names
    I18n.backend.store_translations(:en, :simple_form => { :attributes => { :email => 'E-mail', :message => 'Sent message' } })
    @form.deliver
    assert_match /E\-mail:/, ActionMailer::Base.deliveries.first.body
    assert_match /Sent message:/, ActionMailer::Base.deliveries.first.body
  end

  def test_body_simple_format_messages_with_break_line
    @form.deliver
    assert_no_match /<p>Cool/, ActionMailer::Base.deliveries.first.body

    @advanced.deliver
    assert_match /<p>Cool/, ActionMailer::Base.deliveries.last.body
  end

  def test_form_with_file_includes_an_attachment
    @with_file.deliver

    #For some reason I need to encode the mail before the attachments array returns values
    ActionMailer::Base.deliveries.first.to_s
    assert_equal 1, ActionMailer::Base.deliveries.first.attachments.size
  end

  def test_form_with_file
    @with_file.deliver
    
    assert_no_match /<p>File/, ActionMailer::Base.deliveries.first.body
  end

  def teardown
    I18n.reload!
  end
end
