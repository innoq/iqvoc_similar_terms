# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')
require 'iqvoc/rdfapi'

class SimilarTermsTest < ActionController::TestCase

  setup do
    @controller = SimilarTermsController.new

    forest = Iqvoc::RDFAPI.devour("forest", "a", "skos:Concept") # FIXME: should be ":forest", but https://github.com/innoq/iqvoc/issues/195
    Iqvoc::RDFAPI.devour(forest, "skos:prefLabel", '"forest"@en')
    Iqvoc::RDFAPI.devour(forest, "skos:altLabel", '"woods"@en')
    forest.save

    car = Iqvoc::RDFAPI.devour("car", "a", "skos:Concept") # FIXME: should be ":car"; see above
    Iqvoc::RDFAPI.devour(car, "skos:prefLabel", '"car"@en')
    Iqvoc::RDFAPI.devour(car, "skos:altLabel", '"automobile"@en')
    car.save
  end

  test "routing" do
    assert_raises ActionController::RoutingError do
      get :show
    end
    assert_raises ActionController::RoutingError do
      get :show, :format => "ttl"
    end

    get :show, :lang => "en", :format => "ttl"
    assert_response 400

    get :show, :lang => "en", :format => "ttl", :terms => "foo"
    assert_response 200
    assert !@response.body.include?("skos:altLabel")
  end

  test "RDF representations" do
    get :show, :lang => "en", :format => "ttl", :terms => "forest"
    assert_response :success
    assert @response.body.include?(<<-EOS)
@prefix skos: <http://www.w3.org/2004/02/skos/core#>.
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
