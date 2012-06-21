if defined?(Rails) && Rails::VERSION::MAJOR != 2

  # Rails3 generator invoked with 'rails generate go_static'
  class GoStaticGenerator < Rails::Generators::Base
    source_root(File.expand_path(File.dirname(__FILE__) + "/../../generators/go_static/templates"))
    def copy_initializer
      copy_file 'go_static.rb', 'config/initializers/go_static.rb'
    end
  end

end
