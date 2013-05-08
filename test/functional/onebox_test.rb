# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')
require 'iqvoc/rdfapi'

class OneBoxTest < ActionController::TestCase

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

  test "XML representation" do
    get :show, :lang => "en", :format => "xml", :terms => "foo"
    assert_response 200
    puts "\n\nAAA", "=" * 80, @response.body, "-" * 80
    assert @response.body.starts_with?(<<-EOS.strip)
<?xml version="1.0" encoding="UTF-8"?>
<OneBoxResults xmlns:xlink="http://www.w3.org/1999/xlink">
  <resultCode>success</resultCode>
  <totalResults>0</totalResults>
  <urlText>Similar Terms</urlText>
  <urlLink>http://test.host/en/similar.xml?terms=foo#</urlLink>
    EOS
    assert !@response.body.include?("<MODULE_RESULT>")

    get :show, :lang => "en", :format => "xml", :terms => "forest"
    assert_response 200
    puts "\n\nBBB", "=" * 80, @response.body, "-" * 80
    assert @response.body.include?("<totalResults>2</totalResults>")
    assert @response.body.include?(<<-EOS.strip)
  <MODULE_RESULT>
    <title>similar terms for 'forest'</title>
    EOS
    assert @response.body.include? '<Field name="forest">forest</Field>'
    assert @response.body.include? '<Field name="woods">woods</Field>'
  end

end
