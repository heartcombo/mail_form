class MailForm::Base
  include MailForm::Shim
  include MailForm::Delivery

  def self.lookup_ancestors
    super - [MailForm::Base]
  end
end