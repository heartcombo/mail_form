# coding: utf-8

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require File.join(File.dirname(__FILE__), "lib", "mail_form", "version")

desc 'Run tests for MailForm.'
Rake::TestTask.new(:test) do |t|
  t.libs   << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for MailForm.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'MailForm'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('MIT-LICENSE')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "mail_form"
    s.version = MailForm::VERSION
    s.summary = "Send e-mail straight from forms in Rails with I18n, validations, attachments and request information."
    s.email = "contact@plataformatec.com.br"
    s.homepage = "http://github.com/plataformatec/mail_form"
    s.description = "Send e-mail straight from forms in Rails with I18n, validations, attachments and request information."
    s.authors = ['José Valim', 'Carlos Antônio']
    s.files =  FileList["[A-Z]*", "{lib,views}/**/*"]
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install jeweler"
end
