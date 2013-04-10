# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')
require 'iqvoc/rdfapi' # XXX: only required with Zeus

class SimilarTermsTest < ActionController::TestCase

  setup do
    @controller = SimilarTermsController.new

    forest = Iqvoc::RDFAPI.devour("forest", "a", "skos:Concept") # FIXME: should be ":forest", but https://github.com/innoq/iqvoc/issues/195
    Iqvoc::RDFAPI.devour(forest, "skos:prefLabel", '"forest"@en')
    Iqvoc::RDFAPI.devour(forest, "skos:altLabel", '"woods"@en')
    forest.save

    car = Iqvoc::RDFAPI.devour(":car", "a", "skos:Concept")
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
    assert !@response.body.include?("a sdc:Result")
  end

  test "RDF representations" do
    get :show, :lang => "en", :format => "ttl", :terms => "forest"
    assert_response :success
    assert @response.body.include?(<<-EOS)
@prefix sdc: <http://sindice.com/vocab/search#>.
    EOS
    assert @response.body.include?(<<-EOS)
@prefix skos: <http://www.w3.org/2004/02/skos/core#>.
    EOS
    assert @response.body.include?(<<-EOS)
@prefix query: <http://test.host/en/similar.ttl?terms=forest#>.
    EOS
    assert @response.body.include?(<<-EOS)
query:top a sdc:Query;
    EOS
    assert @response.body.include?(<<-EOS)
query:result1 a sdc:Result;
              rdfs:label "forest"@en;
              sdc:rank 1;
              sdc:link :forest.
    EOS
    assert @response.body.include?(<<-EOS)
query:result2 a sdc:Result;
              rdfs:label "woods"@en;
              sdc:rank 2;
              sdc:link :forest.
    EOS
    assert @response.body.include?(<<-EOS)
:forest a skos:Concept.
    EOS
    # ensure there are no duplicates
    assert_equal 2, @response.body.split("a skos:Concept").length
  end

end
