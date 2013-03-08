# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')

class SimilarTermsTest < ActionController::TestCase

  setup do
    @controller = SimilarTermsController.new
  end

  test "routing" do
    assert_raises ActionController::RoutingError do
      get :show
    end
    assert_raises ActionController::RoutingError do
      get :show, :format => "ttl"
    end

    get :show, :lang => "en", :format => "ttl"
    assert_response :success
  end

end
