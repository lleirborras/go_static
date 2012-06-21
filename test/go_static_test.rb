require 'test_helper'

GoStatic.config = { :exe_path => '/usr/local/bin/wkhtmltoimage' }
HTML_DOCUMENT = "<html><body>Hello World</body></html>"

# Provide a public accessor to the normally-private parse_options function
class GoStatic
  def get_parsed_options(opts)
    parse_options(opts)
  end
end

class GoStaticTest < ActiveSupport::TestCase

  test "should generate PDF from html document" do
    wp = GoStatic.new
    png = wp.png_from_string HTML_DOCUMENT
    assert png.length > 100
  end

  test "should raise exception when no path to wkhtmltopng" do
    assert_raise RuntimeError do
      GoStatic.new " "
    end
  end

  test "should raise exception when wkhtmltopng path is wrong" do
    assert_raise RuntimeError do
      GoStatic.new "/i/do/not/exist/notwkhtmltopng"
    end
  end

  test "should raise exception when wkhtmltopng is not executable" do
    begin
      tmp = Tempfile.new('wkhtmltopng')
      fp = tmp.path
      File.chmod 0000, fp
      assert_raise RuntimeError do
        GoStatic.new fp
      end
    ensure
      tmp.delete
    end
  end

  test "should raise exception when png generation fails" do
    begin
      tmp = Tempfile.new('wkhtmltopng')
      fp = tmp.path
      File.chmod 0777, fp
      wp = GoStatic.new fp
      assert_raise RuntimeError do
        wp.png_from_string HTML_DOCUMENT
      end
    ensure
      tmp.delete
    end
  end

  test "should parse other options" do
    wp = GoStatic.new

=begin
    [ :orientation, :page_size, :proxy, :username, :password, :cover, :dpi,
      :encoding, :user_style_sheet
    ].each do |o|
      assert_equal "--#{o.to_s.gsub('_', '-')} \"opts\"", wp.get_parsed_options(o => "opts").strip
    end

    [:redirect_delay, :zoom, :page_offset].each do |o|
      assert_equal "--#{o.to_s.gsub('_', '-')} 5", wp.get_parsed_options(o => 5).strip
    end

    [ :book, :default_header, :disable_javascript, :grayscale, :lowquality,
      :enable_plugins, :disable_internal_links, :disable_external_links,
      :print_media_type, :disable_smart_shrinking, :use_xserver, :no_background
    ].each do |o|
      assert_equal "--#{o.to_s.gsub('_', '-')}", wp.get_parsed_options(o => true).strip
    end
=end
  end
end
