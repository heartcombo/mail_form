# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "mail_form/version"

Gem::Specification.new do |s|
  s.name        = "mail_form"
  s.version     = MailForm::VERSION.dup
  s.platform    = Gem::Platform::RUBY
  s.summary     = "Send e-mail straight from forms in Rails with I18n, validations, attachments and request information."
  s.email       = "contact@plataformatec.com.br"
  s.homepage    = "https://github.com/plataformatec/mail_form"
  s.description = "Send e-mail straight from forms in Rails with I18n, validations, attachments and request information."
  s.authors     = ['José Valim', 'Carlos Antônio']
  s.license     = 'MIT'

  s.files         = Dir["CHANGELOG", "MIT-LICENSE", "README.md", "lib/**/*"]
  s.test_files    = Dir["test/**/*"]
  s.require_paths = ["lib"]

  s.rubyforge_project = "mail_form"

  s.add_dependency('actionmailer', '>= 3.2')
  s.add_dependency('activemodel', '>= 3.2')
end
