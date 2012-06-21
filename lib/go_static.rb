# wkhtml2image Ruby interface
# http://code.google.com/p/wkhtmltopdf/

require 'logger'
require 'digest/md5'
require 'rbconfig'
require RbConfig::CONFIG['target_os'] == 'mingw32' && !(RUBY_VERSION =~ /1.9/) ? 'win32/open3' : 'open3'
require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/object/blank'

require 'go_static_railtie'
require 'go_static_tempfile'

class GoStatic
  EXE_NAME = "wkhtmltoimage"
  @@config = {}
  cattr_accessor :config

  def initialize(wkhtmltoimage_binary_path = nil)
    @exe_path = wkhtmltoimage_binary_path || find_wkhtmltoimage_binary_path
    raise "Location of #{EXE_NAME} unknown" if @exe_path.empty?
    raise "Bad #{EXE_NAME}'s path" unless File.exists?(@exe_path)
    raise "#{EXE_NAME} is not executable" unless File.executable?(@exe_path)
  end

  def png_from_string(string, options={})
    command = "\"#{@exe_path}\" #{parse_options(options)} - - " # -q for no errors on stdout
    print_command(command) if in_development_mode?
    png, err = Open3.popen3(command) do |stdin, stdout, stderr|
      stdin.binmode
      stdout.binmode
      stderr.binmode
      stdin.write(string)
      stdin.close
      [stdout.read, stderr.read]
    end
    raise "IMAGE could not be generated!" if png and png.rstrip.length == 0
    png
  rescue Exception => e
    raise "Failed to execute:\n#{command}\nError: #{e}"
  end

  private

    def in_development_mode?
      (defined?(Rails) && Rails.env == 'development') ||
        (defined?(RAILS_ENV) && RAILS_ENV == 'development')
    end

    def on_windows?
      RbConfig::CONFIG['target_os'] == 'mingw32'
    end

    def print_command(cmd)
      p "*"*15 + cmd + "*"*15
    end

    def parse_options(options)
      [
        parse_extra(options),
        parse_basic_auth(options),
        parse_others(options)
      ].join(' ')
    end

    def parse_extra(options)
      options[:extra].nil? ? '' : options[:extra]
    end

    def parse_basic_auth(options)
      if options[:basic_auth]
        user, passwd = Base64.decode64(options[:basic_auth]).split(":")
        "--username '#{user}' --password '#{passwd}'"
      else
        ""
      end
    end

    def make_option(name, value, type=:string)
      if value.is_a?(Array)
        return value.collect { |v| make_option(name, v, type) }.join('')
      end
      "--#{name.gsub('_', '-')} " + case type
        when :boolean then ""
        when :numeric then value.to_s
        when :name_value then value.to_s
        else "\"#{value}\""
      end + " "
    end

    def make_options(options, names, prefix="", type=:string)
      names.collect {|o| make_option("#{prefix.blank? ? "" : prefix + "-"}#{o.to_s}", options[o], type) unless options[o].blank?}.join
    end

    def parse_others(options)
      unless options.blank?
        r = make_options(options, [ :cookie,
                                    :custom_header,
                                    :post,
                                    :post_file], "", :name_value)

        r +=make_options(options, [ :crop_h,
                                    :crop_w,
                                    :crop_x,
                                    :crop_y,
                                    :minimum_font_size,
                                    :quality,
                                    :width,
                                    :height,
                                    :javascript_delay,
                                    :zoom], "", :numeric)

        r +=make_options(options, [ :custom_header_propagation,
                                    :no_custom_header_propagation,
                                    :debug_javascript,
                                    :no_debug_javascript,
                                    :help,
                                    :htmldoc,
                                    :images,
                                    :no_images,
                                    :disable_javascript,
                                    :enable_javascript,
                                    :disable_local_file_access,
                                    :enable_local_file_access,
                                    :manpage,
                                    :disable_plugins,
                                    :enable_plugins,
                                    :readme,
                                    :disable_smart_width,
                                    :stop_slow_scripts,
                                    :no_stop_slow_scripts,
                                    :transparent,
                                    :version,
                                    :extended_help])

        r +=make_options(options, [ :allow,
                                    :checkbox_checked_svg,
                                    :checkbox_svg,
                                    :cookie_jar,
                                    :encoding,
                                    :format,
                                    :load_error_handling,
                                    :password,
                                    :proxy,
                                    :radiobutton_checked_svg,
                                    :radiobutton_svg,
                                    :run_script,
                                    :user_style_sheet,
                                    :username,
                                    :window_status])
      end
    end

    def find_wkhtmltoimage_binary_path
      possible_locations = (ENV['PATH'].split(':')+%w[/usr/bin /usr/local/bin ~/bin]).uniq
      exe_path ||= GoStatic.config[:exe_path] unless GoStatic.config.empty?
      exe_path ||= begin
        (defined?(Bundler) ? `bundle exec which wkhtmltoimage` : `which wkhtmltoimage`).chomp
      rescue Exception => e
        nil
      end
      exe_path ||= possible_locations.map{|l| File.expand_path("#{l}/#{EXE_NAME}") }.find{|location| File.exists? location}
      exe_path || ''
    end
end
