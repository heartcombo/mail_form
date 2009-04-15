Gem::Specification.new do |s|
  s.name     = "simple_form"
  s.version  = "0.2.0"
  s.date     = "2009-04-03"
  s.summary  = "Simple easy contact form for Rails."
  s.email    = "jose.valim@gmail.com"
  s.homepage = "http://github.com/josevalim/simple_form"
  s.description = "Simple easy contact form for Rails."
  s.has_rdoc = true
  s.authors  = [ "José Valim" ]
  s.files    = [
    "CHANGELOG",
    "MIT-LICENSE",
    "README",
    "Rakefile",
    "init.rb",
    "lib/simple_form.rb",
    "lib/simple_form/base.rb",
    "lib/simple_form/dsl.rb",
    "lib/simple_form/errors.rb",
    "lib/simple_form/notifier.rb",
    "views/simple_form/notifier/contact.erb"
  ]
  s.test_files = [
    "test/base_test.rb",
    "test/errors_test.rb",
    "test/notifier_test.rb",
    "test/test_helper.rb"
  ]
  s.rdoc_options = ["--main", "README"]
  s.extra_rdoc_files = ["README"]
end
