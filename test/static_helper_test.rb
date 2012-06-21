require 'test_helper'

module ActionController
  class Base
    def render_to_string opts={}
      opts.to_s
    end
  end
end

class StaticHelperTest < ActionController::TestCase
  def setup
    @ac = ActionController::Base.new
  end

  def teardown
    @ac=nil
  end
end
