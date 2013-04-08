# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')
require 'iqvoc/rdfapi' # XXX: only required with Zeus
require 'iqvoc/similar_terms' # XXX: should not be necessary!?

class ResultsTest < ActiveSupport::TestCase

  setup do
    forest = Iqvoc::RDFAPI.devour(":forest", "a", "skos:Concept")
    Iqvoc::RDFAPI.devour(forest, "skos:prefLabel", '"forest"@en')
    Iqvoc::RDFAPI.devour(forest, "skos:altLabel", '"woods"@en')
    forest.save
  end

  test "ranked results" do
    results = Iqvoc::SimilarTerms.ranked("en", "forest")
    assert_equal 2, results.length
    assert_equal Iqvoc::Label.base_class, results[0][0].class
    assert_equal "forest", results[0][0].value
    assert_equal ":forest", results[0][1].origin
    assert_equal "woods", results[1][0].value
    assert_equal ":forest", results[0][1].origin
  end

  test "weighted results" do
    results = Iqvoc::SimilarTerms.weighted("en", "forest")
    assert_equal 2, results.keys.length
    expected = { "forest" => 5, "woods" => 2 }
    results.each do |label, data|
      assert_equal Iqvoc::Label.base_class, label.class
      assert_equal 2, data.length
      assert_equal expected[label.value], data[0]
      assert_equal Iqvoc::Concept.base_class, data[1].class
    end
  end

end
