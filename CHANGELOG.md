# Unreleased


# 1.10.0

* Add support for Rails 7.0 and Ruby 3.1/3.2 (no changes required)
* Add support for multiple files through a single attachment. [#76, #78]
* Remove test files from the gem package.

# 1.9.0

* Add support for Ruby 3.0, drop support for Ruby < 2.5.
* Add support for Rails 6.1, drop support for Rails < 5.2.
* Move CI to GitHub Actions.

# 1.8.1

* Fix Active Record integration when including `Mail::Delivery`.

# 1.8.0

* Added support for Rails 6.0.
* Drop support for Rails < 5.0 and Ruby < 2.4.

# 1.7.1

* Added support for Rails 5.2.

# 1.7.0

* Added support for Rails 5.1.

# 1.6.0

* Support Rails 4.1 and 4.2.

# Version 1.5.0

* Support Rails 4.
* Drop support to Rails < 3.2 and Ruby 1.8.

# Version 1.4

* Fixed bug that was causing all Active Record attributes be saved as nil
* Avoid symbol injection on forms

# Version 1.3

* Removed deprecated methods in version 1.2
* Added persisted? header and a generator

# Version 1.2

* No more class attributes, just define a headers method

# Version 1.1

* Rails 3 compatibility

# Version 1.0

* Rename to mail_form and launch Rails 2.3 branch

# Version 0.4

* Added support to template

# Version 0.3

* Added support to symbols on :sender, :subject and :recipients
* Added support to symbols on :validate

# Version 0.2

* Added support to request objects and append DSL
* Added support to :attachments (thanks to @andrewtimberlake)

# Version 0.1

* First release
