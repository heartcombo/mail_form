<h4 style="text-decoration:underline"><%= message.subject %></h4>

<% @resource.mail_form_attributes.each do |attribute, value|
  next if value.blank? %>

  <p><b><%= @resource.class.human_attribute_name(attribute) %>:</b>
  <%= case value
    when /\n/
      raw(simple_format(h(value)))
    when Time, DateTime, Date
      I18n.l(value)
    else
      value
    end
  %></p>
<% end %>

<% unless @resource.class.mail_appendable.blank? %>
  <br /><h4 style="text-decoration:underline"><%= I18n.t :title, :scope => [ :mail_form, :request ], :default => 'Request information' %></h4>

  <% @resource.class.mail_appendable.each do |attribute|
    value = @resource.request.send(attribute)

    value = if value.is_a?(Hash) && !value.empty?
      list = value.to_a.map{ |k,v| content_tag(:li, h("#{k}: #{v.inspect}")) }.join("\n")
      content_tag(:ul, raw(list), :style => "list-style:none;")
    elsif value.is_a?(String)
      value
    else
      value.inspect
    end
  %>

    <p><b><%= I18n.t attribute, :scope => [ :mail_form, :request ], :default => attribute.to_s.humanize %>:</b>
    <%= value.include?("\n") ? simple_format(value) : value %></p>
  <% end %>
  <br />
<% end %>
