# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')

class SimilarTermsTest < ActionController::TestCase

  setup do
    @controller = SimilarTermsController.new

    forest = Iqvoc::RDFAPI.devour("forest", "a", "skos:Concept") # XXX: should be ":forest", but https://github.com/innoq/iqvoc/issues/195
    Iqvoc::RDFAPI.devour(forest, "skos:prefLabel", '"forest"@en')
    Iqvoc::RDFAPI.devour(forest, "skos:altLabel", '"woods"@en')
    forest.save
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
:forest a skos:Concept.
    EOS
    # XXX: `:result<n>` as subject doesn't actually make sense because it's not a dereferenceable resource
    assert @response.body.include?(<<-EOS)
:result1 a sdc:Result;
         sdc:link :forest;
         skos:prefLabel "forest"@en;
         sdc:rank 1.
    EOS
    assert @response.body.include?(<<-EOS)
:result2 a sdc:Result;
         sdc:link :forest;
         skos:altLabel "woods"@en
         sdc:rank 2.
    EOS
  end

end
