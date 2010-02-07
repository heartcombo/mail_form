require 'test_helper'

class MailFormNotifierTest < ActiveSupport::TestCase

  def setup
    @form = ContactForm.new(:name => 'José', :email => 'my.email@my.domain.com', :message => 'Cool')

    @request          = ActionController::TestRequest.new
    @valid_attributes = { :name => 'José', :email => 'my.email@my.domain.com', :message => "Cool\nno?" }
    @advanced         = AdvancedForm.new(@valid_attributes)
    @advanced.request = @request

    test_file  = Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__), 'test_file.txt'))
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
    assert_equal 'Contact form', first_delivery.subject
  end

  def test_subject_is_a_string
    @advanced.deliver
    assert_equal 'My Advanced Form', first_delivery.subject
  end

  def test_sender_defaults_to_form_email
    @form.deliver
    assert_equal ['my.email@my.domain.com'], first_delivery.from
  end

  def test_error_is_raised_when_recipients_is_nil
    assert_raise ScriptError do
      NullRecipient.new.deliver
    end
  end

  def test_recipients_is_a_string
    @form.deliver
    assert_equal ['my.email@my.domain.com'], first_delivery.to
  end

  def test_recipients_is_an_array
    @advanced.deliver
    assert_equal ['my.first@email.com', 'my.second@email.com'], first_delivery.to
  end

  def test_recipients_is_a_symbold
    @with_file.deliver
    assert_equal ['contact_file@my.domain.com'], first_delivery.to
  end

  def test_headers_is_a_hash
    @advanced.deliver
    assert_equal 'mypath', first_delivery.header['return-path'].to_s
  end

  def test_body_contains_subject
    @form.deliver
    assert_match /Contact form/, first_delivery.body.to_s
  end

  def test_body_contains_attributes_values
    @form.deliver
    assert_match /José/, first_delivery.body.to_s
    assert_match /my.email@my.domain.com/, first_delivery.body.to_s
    assert_match /Cool/, first_delivery.body.to_s
  end

  def test_body_contains_attributes_names
    @form.deliver
    assert_match /Name:/, first_delivery.body.to_s
    assert_match /Email:/, first_delivery.body.to_s
    assert_match /Message:/, first_delivery.body.to_s
  end

  def test_body_contains_localized_attributes_names
    I18n.backend.store_translations(:en, :mail_form => { :attributes => { :contact_form => { :message => 'Sent message' } } })
    @form.deliver
    assert_match /Sent message:/, first_delivery.body.to_s
    assert_no_match /Message:/, first_delivery.body.to_s
  end

  def test_body_mail_format_messages_with_break_line
    @form.deliver
    assert_no_match /<p>Cool/, first_delivery.body.to_s

    @advanced.deliver
    assert_match /<p>Cool/, last_delivery.body.to_s
  end

  def test_body_mail_format_dates_with_i18n
    @form.deliver
    assert_no_match /I18n.l(Date.today)/, first_delivery.body.to_s
  end

  def test_body_does_not_append_request_if_append_is_not_called
    @form.deliver
    assert_no_match /Request information/, first_delivery.body.to_s
  end

  def test_body_does_append_request_if_append_is_called
    @advanced.deliver
    assert_match /Request information/, last_delivery.body.to_s
  end

  def test_request_title_is_localized
    I18n.backend.store_translations(:en, :mail_form => { :request => { :title => 'Information about the request' } })
    @advanced.deliver
    assert_no_match /Request information/, last_delivery.body.to_s
    assert_match /Information about the request/, last_delivery.body.to_s
  end

  def test_request_info_attributes_are_printed
    @advanced.deliver
    assert_match /Remote ip/, last_delivery.body.to_s
    assert_match /User agent/, last_delivery.body.to_s
  end

  def test_request_info_attributes_are_localized
    I18n.backend.store_translations(:en, :mail_form => { :request => { :remote_ip => 'IP Address' } })
    @advanced.deliver
    assert_match /IP Address/, last_delivery.body.to_s
    assert_no_match /Remote ip/, last_delivery.body.to_s
  end

  def test_request_info_values_are_printed
    @advanced.deliver
    assert_match /0\.0\.0\.0/, last_delivery.body.to_s
    assert_match /Rails Testing/, last_delivery.body.to_s
  end

  def test_request_info_hashes_are_print_inside_lis
    @request.session = { :my => :session, :user => "data" }
    @advanced.deliver
    assert_match /<li>my: :session<\/li>/, last_delivery.body.to_s
    assert_match /<li>user: &quot;data&quot;<\/li>/, last_delivery.body.to_s
  end

  def test_error_is_raised_when_append_is_given_but_no_request_is_given
    assert_raise ScriptError do
      @advanced.request = nil
      @advanced.deliver
    end
  end

  def test_form_with_file_includes_an_attachment
    @with_file.deliver
    assert_equal 1, first_delivery.attachments.size
  end

  def test_form_with_file_does_not_output_attachment_as_attribute
    @with_file.deliver
    assert_no_match /File:/, first_delivery.body.to_s
  end

  def test_form_with_customized_template_render_correct_template
    begin
      previous_view_path = MailForm.view_paths
      MailForm.prepend_view_path File.join(File.dirname(__FILE__), 'views')
      @template.deliver
      assert_match 'Hello from my custom template!', last_delivery.body.to_s
    ensure
      MailForm.view_paths = previous_view_path
    end
  end

  protected

    def first_delivery
      ActionMailer::Base.deliveries.first
    end

    def last_delivery
      ActionMailer::Base.deliveries.last
    end
  
    def teardown
      I18n.reload!
    end
end