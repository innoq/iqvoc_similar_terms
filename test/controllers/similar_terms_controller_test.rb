# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')

class SimilarTermsControllerTest < ActionController::TestCase

  setup do
    load_test_data
  end

  test "routing" do
    get :show, params: {
      lang: 'en',
      format: 'ttl'
    }
    assert_response 400

    get :show, params: {
      lang: 'en',
      format: 'ttl',
      terms: 'foo'
    }
    assert_response 200
    assert !@response.body.include?("skosxl:altLabel")
  end

  test "single RDF representation" do
    get :show, params: {
      lang: 'en',
      format: 'ttl',
      terms: 'forest'
    }
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
  end

  test "multipe RDF representations" do
    get :show, params: {
      lang: 'en',
      format: 'ttl',
      terms: 'forest,automobile'
    }
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

  test "XML representation without results" do
    get :show, params: {
      lang: 'en',
      format: 'xml',
      terms: 'foo'
    }
    assert_response 200
    assert @response.body.starts_with?(<<-EOS.strip)
<?xml version="1.0" encoding="UTF-8"?>
<OneBoxResults xmlns:xlink="http://www.w3.org/1999/xlink">
  <resultCode>success</resultCode>
  <totalResults>0</totalResults>
  <urlText>Similar Terms</urlText>
  <urlLink>http://test.host/en/similar.xml?terms=foo#</urlLink>
    EOS
    assert !@response.body.include?("<MODULE_RESULT>")
  end

  test "XML representation with results" do
    get :show, params: {
      lang: 'en',
      format: 'xml',
      terms: 'forest'
    }
    assert_response 200
    assert @response.body.include?("<totalResults>2</totalResults>")
    assert @response.body.include?(<<-EOS.strip)
  <MODULE_RESULT>
    <title>similar terms for 'forest'</title>
    EOS
    assert @response.body.include? '<Field name="forest">forest</Field>'
    assert @response.body.include? '<Field name="woods">woods</Field>'
  end

  test "RDF representation with pref labels of narrower and related concepts" do
    SkosImporter.new('test/concept_test.nt', 'http://localhost:3000/').run
    get :show, params: {
      lang: 'en',
      format: 'ttl',
      terms: 'water'
    }
    assert_response :success
    assert @response.body.include?(<<-EOS.strip)
query:top skos:altLabel "new water"@en;
          skos:altLabel "real water"@en;
          skos:altLabel "related"@en;
          skos:altLabel "used water"@en;
          skos:altLabel "water"@en.
EOS
  end

  test "RDF representation with pref labels of narrower and related concepts - case insensitive" do
    SkosImporter.new('test/concept_test.nt', 'http://localhost:3000/').run
    get :show, params: {
      lang: 'en',
      format: 'ttl',
      :terms => 'Water'
    }
    assert_response :success
    assert @response.body.include?(<<-EOS.strip)
query:top skos:altLabel "new water"@en;
          skos:altLabel "real water"@en;
          skos:altLabel "related"@en;
          skos:altLabel "used water"@en;
          skos:altLabel "water"@en.
EOS
  end

  test "Compound Forms in RDF representation" do
    SkosImporter.new('test/compound_forms.nt', 'http://hobbies.com/').run
    get :show, params: {
      lang: 'en',
      format: 'ttl',
      terms: 'Computer'
    }
    assert_response :success
    assert @response.body.include?(<<-EOS.strip)
      query:top skos:altLabel "Computer programming"@en.
      EOS
  end

  test "Compound Forms in RDF representation - case insensitive" do
    SkosImporter.new('test/compound_forms.nt', 'http://hobbies.com/').run
    get :show, params: {
      lang: 'en',
      format: 'ttl',
      terms: 'computer'
    }
    assert_response :success
    assert @response.body.include?(<<-EOS.strip)
      query:top skos:altLabel "Computer programming"@en.
      EOS
  end

end
