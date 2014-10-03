require 'minitest/autorun'

RAILS_ENV = ENV["RAILS_ENV"] = "test"

$:.unshift File.dirname(__FILE__) + '/../lib'
require 'mail_form'

require 'active_support'
require 'active_support/test_case'
require 'active_support/string_inquirer'
require 'action_controller'
require 'action_controller/test_case'
require 'action_mailer'

if ActiveSupport::TestCase.respond_to?(:test_order=)
  ActiveSupport::TestCase.test_order = :random
end

ActionMailer::Base.delivery_method = :test
I18n.enforce_available_locales = false

module Rails
  def self.env
    @env ||= ActiveSupport::StringInquirer.new('test')
  end
end

class ContactForm < MailForm::Base
  attribute :name,     :validate => true
  attribute :email,    :validate => /[^@]+@[^\.]+\.[\w\.\-]+/
  attribute :category, :validate => ["Interface bug", "General"], :allow_blank => true
  attribute :nickname, :captcha => true

  attributes :created_at, :message, :validate => :callback

  def headers
    { :to => 'my.email@my.domain.com' }
  end

  def initialize(*)
    super
    @_callback_run = false
  end

  def callback
    @_callback_run = true
  end

  def callback_run?
    @_callback_run
  end
end

class AdvancedForm < ContactForm
  append :remote_ip, :user_agent, :session

  def headers
    { :to => [ 'my.first@email.com', 'my.second@email.com' ],
      :subject => "My Advanced Form",
      :from => %{"#{name}" <#{email}>},
      "return-path" => "mypath"
    }
  end
end

class FileForm < ContactForm
  attribute :file, :attachment => true, :validate => true

  def headers
    to = if file
      "contact_file@my.domain.com"
    else
      "contact@my.domain.com"
    end
    { :to => to }
  end
end

# Needed to correctly test an uploaded file
class Rack::Test::UploadedFile
  def read
    @tempfile.read
  end
end
