require 'test_helper'
require 'action_view/test_case'

class GoStaticHelperTest < ActionView::TestCase
  test 'go_static_stylesheet_link_tag should inline the stylesheets passed in' do
    assert_equal "<style type='text/css'>/* Wicked styles */\n</style>",
                 go_static_stylesheet_link_tag('../../vendor/plugins/go_static/test/fixtures/wicked')
  end

  test 'go_static_image_tag should return the same as image_tag when passed a full path' do
    assert_equal image_tag("file://#{Rails.root.join('public','images','png')}"),
                 go_static_image_tag('png')
  end

  test 'go_static_javascript_src_tag should return the same as javascript_src_tag when passed a full path' do
    assert_equal javascript_src_tag("file://#{Rails.root.join('public','javascripts','png')}", {}),
                 go_static_javascript_src_tag('png')
  end

  test 'go_static_include_tag should return many go_static_javascript_src_tags' do
    assert_equal [go_static_javascript_src_tag('foo'), go_static_javascript_src_tag('bar')].join("\n"),
                 go_static_javascript_include_tag('foo', 'bar')
  end
end
