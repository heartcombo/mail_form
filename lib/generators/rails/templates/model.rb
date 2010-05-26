class <%= class_name %> < MailForm::Base
<% attributes.each do |attribute| -%>
  attribute :<%= attribute.name %>
<% end -%>

  def headers
    { :to => "PLEASE-CHANGE-ME@example.org" }
  end
end