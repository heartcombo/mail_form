# coding: utf-8

require 'test_helper'

class MailFormNotifierTest < ActiveSupport::TestCase

  def setup
    @form = ContactForm.new(:name => 'José', :email => 'my.email@my.domain.com', :message => 'Cool')

    @request = if ActionPack.respond_to?(:version) && ActionPack.version >= Gem::Version.new('5.1')
                 ActionController::TestRequest.create(Class.new) # Rails 5.1
               elsif ActionPack.respond_to?(:version) && ActionPack.version >= Gem::Version.new('5.0')
                 ActionController::TestRequest.create # Rails 5
               else
                 ActionController::TestRequest.new
               end
    @valid_attributes = { :name => 'José', :email => 'my.email@my.domain.com', :message => "Cool\nno?" }
    @advanced         = AdvancedForm.new(@valid_attributes)
    @advanced.request = @request

    test_file  = Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__), 'test_file.txt'))
    @with_file = FileForm.new(:name => 'José', :email => 'my.email@my.domain.com', :message => "Cool", :file => test_file)

    ActionMailer::Base.deliveries = []
  end

  def test_email_is_sent
    @form.deliver
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  def test_subject_defaults_to_human_class_name
    @form.deliver
    assert_equal 'Contact form', first_delivery.subject
  end

  def test_body_contains_subject
    @form.deliver
    assert_match %r[Contact form], first_delivery.body.to_s
  end

  def test_body_contains_attributes_values
    @form.deliver
    assert_match %r[José], first_delivery.body.to_s
    assert_match %r[my.email@my.domain.com], first_delivery.body.to_s
    assert_match %r[Cool], first_delivery.body.to_s
  end

  def test_body_contains_attributes_names
    @form.deliver
    assert_match %r[Name:], first_delivery.body.to_s
    assert_match %r[Email:], first_delivery.body.to_s
    assert_match %r[Message:], first_delivery.body.to_s
  end

  def test_body_contains_localized_attributes_names
    I18n.backend.store_translations(:en, :mail_form => { :attributes => { :contact_form => { :message => 'Sent message' } } })
    @form.deliver
    assert_match %r[Sent message:], first_delivery.body.to_s
    assert_no_match %r[Message:], first_delivery.body.to_s
  end

  def test_body_mail_format_messages_with_break_line
    @form.deliver
    assert_no_match %r[<p>Cool], first_delivery.body.to_s

    @advanced.deliver
    assert_match %r[<p>Cool], last_delivery.body.to_s
  end

  def test_body_mail_format_dates_with_i18n
    @form.deliver
    assert_no_match %r[I18n.l(Date.today)], first_delivery.body.to_s
  end

  def test_body_does_not_append_request_if_append_is_not_called
    @form.deliver
    assert_no_match %r[Request information], first_delivery.body.to_s
  end

  def test_body_does_append_request_if_append_is_called
    @advanced.deliver
    assert_match %r[Request information], last_delivery.body.to_s
  end

  def test_request_title_is_localized
    I18n.backend.store_translations(:en, :mail_form => { :request => { :title => 'Information about the request' } })
    @advanced.deliver
    assert_no_match %r[Request information], last_delivery.body.to_s
    assert_match %r[Information about the request], last_delivery.body.to_s
  end

  def test_request_info_attributes_are_printed
    @advanced.deliver
    assert_match %r[Remote ip], last_delivery.body.to_s
    assert_match %r[User agent], last_delivery.body.to_s
  end

  def test_request_info_attributes_are_localized
    I18n.backend.store_translations(:en, :mail_form => { :request => { :remote_ip => 'IP Address' } })
    @advanced.deliver
    assert_match %r[IP Address], last_delivery.body.to_s
    assert_no_match %r[Remote ip], last_delivery.body.to_s
  end

  def test_request_info_values_are_printed
    @advanced.deliver
    assert_match %r[0\.0\.0\.0], last_delivery.body.to_s
    assert_match %r[Rails Testing], last_delivery.body.to_s
  end

  def test_request_info_hashes_are_print_inside_lists
    @request.session = { :my => :session, :user => "data" }
    @advanced.deliver
    assert_match %r[<ul], last_delivery.body.to_s
    assert_match %r[<li>my: :session<\/li>], last_delivery.body.to_s
    assert_match %r[<li>user: \S+data\S+<\/li>], last_delivery.body.to_s
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
    assert_no_match %r[File:], first_delivery.body.to_s
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
