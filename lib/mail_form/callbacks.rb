module MailForm::Callbacks
  def self.extended(base)
    base.class_eval do
      include ActiveSupport::Callbacks
      define_callbacks :create, :terminator => "result == false", :scope => [:kind, :name]
    end
  end

  def before_create(*args, &block)
    set_callback(:create, :before, *args, &block)
  end

  def around_create(*args, &block)
    set_callback(:create, :around, *args, &block)
  end

  def after_create(*args, &block)
    options = args.extract_options!
    options[:prepend] = true
    options[:if] = Array(options[:if]) << "!halted && value != false"
    set_callback(:create, :after, *(args << options), &block)
  end
end