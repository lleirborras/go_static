require 'static_helper'
require 'go_static_helper'

if defined?(Rails)

  if Rails::VERSION::MAJOR == 2

    unless ActionController::Base.instance_methods.include? "render_with_go_static"
      ActionController::Base.send :include, StaticHelper
    end
    unless ActionView::Base.instance_methods.include? "go_static_stylesheet_link_tag"
      ActionView::Base.send :include, GoStaticHelper
    end

  else

    class StaticRailtie < Rails::Railtie
      initializer "go_static.register" do |app|
        ActionController::Base.send :include, StaticHelper
        if Rails::VERSION::MINOR > 0
          ActionView::Base.send :include, GoStaticHelper::Assets
        else
          ActionView::Base.send :include, GoStaticHelper
        end
      end
    end

  end

end
