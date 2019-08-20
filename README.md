## MailForm

[![Gem Version](https://fury-badge.herokuapp.com/rb/mail_form.svg)](http://badge.fury.io/rb/mail_form)
[![Build Status](https://api.travis-ci.org/plataformatec/mail_form.svg?branch=master)](http://travis-ci.org/plataformatec/mail_form)
[![Code Climate](https://codeclimate.com/github/plataformatec/mail_form.svg)](https://codeclimate.com/github/plataformatec/mail_form)

### Rails 5

This gem was built on top of `ActiveModel` to showcase how you can pull in validations, naming
and `i18n` from Rails to your models without the need to implement it all by yourself.

This README refers to the **MailForm** gem to be used in Rails 5+. For instructions
on how to use MailForm in older versions of Rails, please refer to the available branches.

### Description

**MailForm** allows you to send an e-mail straight from a form. For instance,
if you want to make a contact form just the following lines are needed (including the e-mail):

```ruby
class ContactForm < MailForm::Base
  attribute :name,      :validate => true
  attribute :email,     :validate => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  attribute :file,      :attachment => true

  attribute :message
  attribute :nickname,  :captcha  => true

  # Declare the e-mail headers. It accepts anything the mail method
  # in ActionMailer accepts.
  def headers
    {
      :subject => "My Contact Form",
      :to => "your.email@your.domain.com",
      :from => %("#{name}" <#{email}>)
    }
  end
end
```

Then you start a console with `rails console` and type:

```ruby
>> c = ContactForm.new(:name => 'José', :email => 'jose@email.com', :message => 'Cool!')
>> c.deliver
```

Check your inbox and the e-mail will be there, with the sent fields (assuming that
you configured your mailer delivery method properly).

### MailForm::Base

When you inherit from `MailForm::Base`, it pulls down a set of stuff from `ActiveModel`,
as `ActiveModel::Validation`, `ActiveModel::Translation` and `ActiveModel::Naming`.

This brings `I18n`, error messages, validations and attributes handling like in
`ActiveRecord` to **MailForm**, so **MailForm** can be used in your controllers and form builders without extra tweaks. This also means that instead of the following:

```ruby
attribute :email, :validate => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
```

You could actually do this:

```ruby
attribute :email
validates_format_of :email, :with => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
```

Choose the one which pleases you the most. For more information on the API, please
continue reading below.

### Playing together ORMs

**MailForm** plays nice with ORMs as well. You just need to include `MailForm::Delivery`
in your model and declare which attributes should be sent:

```ruby
class User < ActiveRecord::Base
  include MailForm::Delivery

  append :remote_ip, :user_agent, :session
  attributes :name, :email, :created_at

  def headers
    {
      :to => "your.email@your.domain.com",
      :subject => "User created an account"
    }
  end
end
```

The delivery will be triggered in an `after_create` hook.

## Installation

Install **MailForm** is very easy. Just edit your Gemfile adding the following:

```ruby
gem 'mail_form'
```
Then run `bundle install` to install **MailForm**.

If you want it as plugin, just do:

`script/plugin install git://github.com/plataformatec/mail_form.git`

## API Overview

### attributes(*attributes)

Declare your form attributes. All attributes declared here will be appended
to the e-mail, except the ones :captcha is true.

Options:

* :validate - A hook to validates_*_of. When true is given, validates the
  presence of the attribute. When a regexp, validates format. When array,
  validates the inclusion of the attribute in the array.

  Whenever :validate is given, the presence is automatically checked. Give
  :allow_blank => true to override.

  Finally, when :validate is a symbol, the method given as symbol will be
  called. Then you can add validations as you do in ActiveRecord (errors.add).

* :attachment - When given, expects a file to be sent and attaches
  it to the e-mail. Don't forget to set your form to multitype.

* :captcha - When true, validates the attributes must be blank.
  This is a simple way to avoid spam and the input should be hidden with CSS.

Examples:

```ruby
class ContactForm < MailForm::Base
  attributes :name,  :validate => true
  attributes :email, :validate => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  attributes :type,  :validate => ["General", "Interface bug"]
  attributes :message
  attributes :screenshot, :attachment => true, :validate => :interface_bug?
  attributes :nickname,   :captcha => true

  def interface_bug?
    if type == 'Interface bug' && screenshot.nil?
      self.errors.add(:screenshot, "can't be blank on interface bugs")
    end
  end
end

c = ContactForm.new(:nickname => 'not_blank', :email => 'your@email.com', :name => 'José')
c.valid?  #=> true
c.spam?   #=> true  (raises an error in development, to remember you to hide it)
c.deliver  #=> false (just delivers if is not a spam and is valid, raises an error in development)

c = ContactForm.new(:email => 'invalid')
c.valid?               #=> false
c.errors.inspect       #=> { :name => :blank, :email => :invalid }
c.errors.full_messages #=> [ "Name can't be blank", "Email is invalid" ]

c = ContactForm.new(:name => 'José', :email => 'your@email.com')
c.deliver
```

### append(*methods)

**MailForm** also makes easy to append request information from client to the sent
mail. You just have to do:

```ruby
class ContactForm < MailForm::Base
  append :remote_ip, :user_agent, :session
  # ...
end
```

And in your controller:

```ruby
@contact_form = ContactForm.new(params[:contact_form])
@contact_form.request = request
```

The remote ip, user agent and session will be sent in the e-mail in a
request information session. You can give to append any method that the
request object responds to.

## I18n

I18n in **MailForm** works like in ActiveRecord, so all models, attributes and messages
can be used with localized. Below is an I18n file example file:

```ruby
mail_form:
  models:
    contact_form: "Your site contact form"
  attributes:
    contact_form:
      email: "E-mail"
      telephone: "Telephone number"
      message: "Sent message"
  request:
    title: "Technical information about the user"
    remote_ip: "IP Address"
    user_agent: "Browser"
```

## Custom e-mail template

To customize the e-mail template that is used create a file called contact.erb in app/views/mail_form.
Take a look at lib/mail_form/views/mail_form/contact.erb in this repo to see how the default template works.

## Maintainers

* José Valim - http://github.com/josevalim
* Carlos Antonio - http://github.com/carlosantoniodasilva

## Contributors

* Andrew Timberlake - http://github.com/andrewtimberlake

## Bugs and Feedback

If you discover any bug, please use github issues tracker.

Copyright (c) 2009-2019 Plataformatec http://plataformatec.com.br/
