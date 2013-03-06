# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')
require 'iqvoc/similar_terms' # XXX: should not be necessary!?

class EntityResolutionTest < ActiveSupport::TestCase

  setup do
    forest = Iqvoc::RDFAPI.devour(:forest, "a", "skos:Concept")
    Iqvoc::RDFAPI.devour(forest, "skos:prefLabel", '"forest"@en')
    Iqvoc::RDFAPI.devour(forest, "skos:altLabel", '"woods"@en')
    forest.save
  end

  test "concept resolution" do
    concepts = Iqvoc::SimilarTerms.term_to_concepts("forest", "en")
    assert_equal 1, concepts.length
    assert_equal Iqvoc::Concept.base_class, concepts[0].class

    concepts = Iqvoc::SimilarTerms.term_to_concepts("forest", "de")
    assert_equal 0, concepts.count

    concepts = Iqvoc::SimilarTerms.term_to_concepts("foo", "en")
    assert_equal 0, concepts.count
  end

  test "label resolution" do
    labels = Iqvoc::SimilarTerms.term_to_labels("forest", "en")
    assert_equal ActiveRecord::Relation, labels.class
    labels = labels.all
    assert_equal 1, labels.length
    assert_equal Iqvoc::Label.base_class, labels[0].class
    assert_equal "forest", labels[0].value
    assert_equal "en", labels[0].language

    labels = Iqvoc::SimilarTerms.term_to_labels("forest", "de")
    assert_equal 0, labels.count

    labels = Iqvoc::SimilarTerms.term_to_labels("foo", "en")
    assert_equal 0, labels.count

    # TODO: test XLLabel and Inflectional variants
  end

end
