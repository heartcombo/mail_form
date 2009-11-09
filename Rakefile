require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require File.join(File.dirname(__FILE__), "lib", "simple_form", "version")

desc 'Run tests for SimpleForm.'
Rake::TestTask.new(:test) do |t|
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for SimpleForm.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'SimpleForm'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('MIT-LICENSE')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "simple_form"
    s.version = SimpleForm::VERSION
    s.summary = "Simple easy contact form for Rails with I18n, validations, attachments and request information."
    s.email = "contact@plataformatec.com.br"
    s.homepage = "http://github.com/josevalim/simple_form"
    s.description = "Simple easy contact form for Rails with I18n, validations, attachments and request information."
    s.authors = ['José Valim', 'Carlos Antônio']
    s.files =  FileList["[A-Z]*", "{lib}/**/*"]
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install jeweler"
end
