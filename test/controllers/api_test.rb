# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')

class SimilarTermsTest < ActionController::TestCase

  setup do
    @controller = SimilarTermsController.new
    
    load_test_data
  end

  test "routing" do
    get :show, :lang => "en", :format => "ttl"
    assert_response 400

    get :show, :lang => "en", :format => "ttl", :terms => "foo"
    assert_response 200
    assert !@response.body.include?("skosxl:altLabel")
  end

  test "RDF representations" do
    get :show, :lang => "en", :format => "ttl", :terms => "forest"
    assert_response :success
    assert @response.body.include?(<<-EOS)
@prefix skos: <http://www.w3.org/2004/02/skos/core#>.
    EOS
    assert @response.body.include?(<<-EOS)
@prefix skosxl: <http://www.w3.org/2008/05/skos-xl#>.
    EOS
    assert @response.body.include?(<<-EOS)
@prefix query: <http://test.host/en/similar.ttl?terms=forest#>.
    EOS
    assert @response.body.include?(<<-EOS.strip)
query:top skos:altLabel "forest"@en;
          skos:altLabel "woods"@en.
    EOS

    get :show, :lang => "en", :format => "ttl", :terms => "forest,automobile"
    assert_response :success
    assert @response.body.include?(<<-EOS)
@prefix skos: <http://www.w3.org/2004/02/skos/core#>.
    EOS
    assert @response.body.include?(<<-EOS)
@prefix skosxl: <http://www.w3.org/2008/05/skos-xl#>.
    EOS
    assert @response.body.include?(<<-EOS)
@prefix query: <http://test.host/en/similar.ttl?terms=forest%2Cautomobile#>.
    EOS
    assert @response.body.include?(<<-EOS.strip)
query:top skos:altLabel "automobile"@en;
          skos:altLabel "car"@en;
          skos:altLabel "forest"@en;
          skos:altLabel "woods"@en.
    EOS
  end

end
