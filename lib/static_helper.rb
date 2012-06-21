module StaticHelper
  require 'go_static'
  require 'go_static_tempfile'

  def self.included(base)
    base.class_eval do
      alias_method_chain :render, :go_static
      alias_method_chain :render_to_string, :go_static
      after_filter :clean_temp_files
    end
  end

  def render_with_go_static(options = nil, *args, &block)
    if options.is_a?(Hash) && options.has_key?(:png)
      log_png_creation
      options[:basic_auth] = set_basic_auth(options)
      make_and_send_png(options.delete(:png), (GoStatic.config || {}).merge(options))
    else
      render_without_go_static(options, *args, &block)
    end
  end

  def render_to_string_with_go_static(options = nil, *args, &block)
    if options.is_a?(Hash) && options.has_key?(:png)
      log_png_creation
      options[:basic_auth] = set_basic_auth(options)
      options.delete :png
      make_png((GoStatic.config || {}).merge(options))
    else
      render_to_string_without_go_static(options, *args, &block)
    end
  end

  private

    def log_png_creation
      logger.info '*'*15 + 'STATIC' + '*'*15
    end

    def set_basic_auth(options={})
      options[:basic_auth] ||= GoStatic.config.fetch(:basic_auth){ false }
      if options[:basic_auth] && request.env["HTTP_AUTHORIZATION"]
        request.env["HTTP_AUTHORIZATION"].split(" ").last
      end
    end

    def clean_temp_files
      if defined?(@hf_tempfiles)
        @hf_tempfiles.each { |tf| tf.close! }
      end
    end

    def make_png(options = {})
      html_string = render_to_string(:template => options[:template], :layout => options[:layout], :formats => options[:formats], :handlers => options[:handlers])
      w = GoStatic.new(options[:wkhtmltoimage])
      w.png_from_string(html_string)
    end

    def make_and_send_png(png_name, options={})
      options[:wkhtmltoimage] ||= nil
      options[:layout]      ||= false
      options[:template]    ||= File.join(controller_path, action_name)
      options[:disposition] ||= "inline"
      if options[:show_as_html]
        render :template => options[:template], :layout => options[:layout], :formats => options[:formats], :handlers => options[:handlers], :content_type => "text/html"
      else
        png_content = make_png(options)
        File.open(options[:save_to_file], 'wb') {|file| file << png_content } if options[:save_to_file]
        send_data(png_content, :filename => png_name + '.png', :type => 'application/png', :disposition => options[:disposition]) unless options[:save_only]
      end
    end
end
