class MailForm::Resource
  include MailForm::Shim
  include MailForm::Delivery

  def self.lookup_ancestors
    super - [MailForm::Resource]
  end
end