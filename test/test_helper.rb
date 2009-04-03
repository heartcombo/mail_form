require 'test/unit'
require 'rubygems'

RAILS_ENV = ENV["RAILS_ENV"] = "test"

require 'active_support'
require 'active_support/test_case'
require 'action_mailer'

ActionMailer::Base.delivery_method = :test

# Load respond_to before defining ApplicationController
require File.dirname(__FILE__) + '/../lib/simple_form.rb'

class ContactForm < SimpleForm
  recipients 'my.email@my.domain.com'

  attribute :name,     :validate => true
  attribute :email,    :validate => /[^@]+@[^\.]+\.[\w\.\-]+/
  attribute :nickname, :captcha => true
  attributes :tellphone, :message
end

class AdvancedForm < ContactForm
  recipients [ 'my.first@email.com', 'my.second@email.com' ]
  subject 'My Advanced Form'
  sender{|c| %{"#{c.name}" <#{c.email}>} }
  headers 'return-path' => 'mypath'
end

class NullRecipient < SimpleForm
  sender 'my.email@my.domain.com'
end
