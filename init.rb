require 'go_static'
require 'go_static_tempfile'

unless ActionController::Base.instance_methods.collect(&:to_s).include? "render_with_go_static"
  require 'static_helper'
  ActionController::Base.send :include, StaticHelper
end

unless ActionView::Base.instance_methods.collect(&:to_s).include? "go_static_stylesheet_link_tag"
  require 'go_static_helper'
  ActionView::Base.send :include, GoStaticHelper
end

Mime::Type.register 'image/png', :png
