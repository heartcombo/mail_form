require 'test/unit'
require 'rubygems'

RAILS_ENV = ENV["RAILS_ENV"] = "test"

require 'active_support'
require 'active_support/test_case'
require 'action_mailer'
require 'action_controller/test_case'

ActionMailer::Base.delivery_method = :test

# Load respond_to before defining ApplicationController
require File.dirname(__FILE__) + '/../lib/simple_form.rb'

class ContactForm < SimpleForm
  recipients 'my.email@my.domain.com'

  attribute :name,     :validate => true
  attribute :email,    :validate => /[^@]+@[^\.]+\.[\w\.\-]+/
  attribute :nickname, :captcha => true
  attributes :tellphone, :message, :validate => :callback

  def callback
    @_callback_run = true
  end
end

class AdvancedForm < ContactForm
  append :remote_ip, :user_agent, :session

  recipients [ 'my.first@email.com', 'my.second@email.com' ]
  subject 'My Advanced Form'
  sender{|c| %{"#{c.name}" <#{c.email}>} }
  headers 'return-path' => 'mypath'
end

class FileForm < ContactForm
  attribute :file, :attachment => true, :validate => true
  recipients :set_recipient

  def set_recipient
    if file
      "contact_file@my.domain.com"
    else
      "contact@my.domain.com"
    end
  end
end

class NullRecipient < SimpleForm
  sender 'my.email@my.domain.com'
end

# Needed to correctly test an uploaded file
class ActionController::TestUploadedFile
  def read
    @tempfile.read
  end
end
