class GoStaticGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.file "go_static.rb", "config/initializers/go_static.rb"
    end
  end
end
