source 'https://rubygems.org'

gemspec path: '..'

gem 'rake'
gem 'rdoc'

gem 'actionmailer', '~> 4.2.0'
gem 'activemodel', '~> 4.2.0'

gem "mime-types", (RUBY_VERSION >= "2.0" ? "~> 3.0" : "~> 2.99")
# https://github.com/sparklemotion/nokogiri/blob/ad010b28c6edbc3b40950a72f3af692737b578b6/CHANGELOG.md#backwards-incompatibilities
gem "nokogiri", (RUBY_VERSION >= "2.1" ? "~> 1.7" : "< 1.7")
