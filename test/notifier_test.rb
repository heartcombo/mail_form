require File.dirname(__FILE__) + '/test_helper'

class MailFormNotifierTest < ActiveSupport::TestCase

  def setup
    @form = ContactForm.new(:name => 'José', :email => 'my.email@my.domain.com', :message => 'Cool')

    @request          = ActionController::TestRequest.new
    @valid_attributes = { :name => 'José', :email => 'my.email@my.domain.com', :message => "Cool\nno?" }
    @advanced         = AdvancedForm.new(@valid_attributes, @request)

    test_file  = ActionController::TestUploadedFile.new(File.join(File.dirname(__FILE__), 'test_file.txt'))
    @with_file = FileForm.new(:name => 'José', :email => 'my.email@my.domain.com', :message => "Cool", :file => test_file)

    @template = TemplateForm.new(@valid_attributes)

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
    assert_equal ['my.first@email.com', 'my.second@email.com'], ActionMailer::Base.deliveries.first.to
  end

  def test_recipients_is_a_symbold
    @with_file.deliver
    assert_equal ['contact_file@my.domain.com'], ActionMailer::Base.deliveries.first.to
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
    I18n.backend.store_translations(:en, :mail_form => { :attributes => { :message => 'Sent message' } })
    @form.deliver
    assert_match /Sent message:/, ActionMailer::Base.deliveries.first.body
    assert_no_match /Message:/, ActionMailer::Base.deliveries.first.body
  end

  def test_body_mail_format_messages_with_break_line
    @form.deliver
    assert_no_match /<p>Cool/, ActionMailer::Base.deliveries.first.body

    @advanced.deliver
    assert_match /<p>Cool/, ActionMailer::Base.deliveries.last.body
  end

  def test_body_does_not_append_request_if_append_is_not_called
    @form.deliver
    assert_no_match /Request information/, ActionMailer::Base.deliveries.first.body
  end

  def test_body_does_append_request_if_append_is_called
    @advanced.deliver
    assert_match /Request information/, ActionMailer::Base.deliveries.last.body
  end

  def test_request_title_is_localized
    I18n.backend.store_translations(:en, :mail_form => { :request => { :title => 'Information about the request' } })
    @advanced.deliver
    assert_no_match /Request information/, ActionMailer::Base.deliveries.last.body
    assert_match /Information about the request/, ActionMailer::Base.deliveries.last.body
  end

  def test_request_info_attributes_are_printed
    @advanced.deliver
    assert_match /Remote ip/, ActionMailer::Base.deliveries.last.body
    assert_match /User agent/, ActionMailer::Base.deliveries.last.body
  end

  def test_request_info_attributes_are_localized
    I18n.backend.store_translations(:en, :mail_form => { :request => { :remote_ip => 'IP Address' } })
    @advanced.deliver
    assert_match /IP Address/, ActionMailer::Base.deliveries.last.body
    assert_no_match /Remote ip/, ActionMailer::Base.deliveries.last.body
  end

  def test_request_info_values_are_printed
    @advanced.deliver
    assert_match /0\.0\.0\.0/, ActionMailer::Base.deliveries.last.body
    assert_match /Rails Testing/, ActionMailer::Base.deliveries.last.body
  end

  def test_request_info_hashes_are_print_inside_lis
    @request.session = { :my => :session, :user => "data" }
    @advanced.deliver
    assert_match /<li>my: :session<\/li>/, ActionMailer::Base.deliveries.last.body
    assert_match /<li>user: &quot;data&quot;<\/li>/, ActionMailer::Base.deliveries.last.body
  end

  def test_error_is_raised_when_append_is_given_but_no_request_is_given
    assert_raise ScriptError do
      @advanced.request = nil
      @advanced.deliver
    end
  end

  def test_form_with_file_includes_an_attachment
    @with_file.deliver

    #For some reason I need to encode the mail before the attachments array returns values
    ActionMailer::Base.deliveries.first.to_s
    assert_equal 1, ActionMailer::Base.deliveries.first.attachments.size
  end

  def test_form_with_file_does_not_output_attachment_as_attribute
    @with_file.deliver
    assert_no_match /File/, ActionMailer::Base.deliveries.first.body
  end

  def test_form_with_customized_template_raise_missing_template_if_not_found
    assert_raise ActionView::MissingTemplate do
      @template.deliver
    end
  end

  def test_form_with_customized_template_render_correct_template
    begin
      default_template_root = MailForm::Notifier.template_root
      MailForm::Notifier.template_root = File.join(File.dirname(__FILE__), 'views')
      @template.deliver
      assert_match 'Hello from my cystom template!', ActionMailer::Base.deliveries.last.body
    ensure
      MailForm::Notifier.template_root = default_template_root
    end
  end

  def teardown
    I18n.reload!
  end
end
