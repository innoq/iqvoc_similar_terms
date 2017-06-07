# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')

class EntityResolutionTest < ActiveSupport::TestCase

  setup do
    load_test_data
  end

  test "concept resolution" do
    concepts = Iqvoc::SimilarTerms.terms_to_concepts("en", "forest")
    assert_equal 1, concepts.length
    assert_equal Iqvoc::Concept.base_class, concepts[0].class

    concepts = Iqvoc::SimilarTerms.terms_to_concepts("de", "forest")
    assert_equal 0, concepts.count

    concepts = Iqvoc::SimilarTerms.terms_to_concepts("en", "foo")
    assert_equal 0, concepts.count
  end

  test "label resolution" do
    labels = Iqvoc::SimilarTerms.terms_to_labels("en", "forest")
    # assert_equal ActiveRecord::Relation, labels.class
    labels = labels.all

    assert_equal 1, labels.length
    assert_equal Iqvoc::XLLabel.base_class, labels[0].class
    assert_equal "forest", labels[0].value
    assert_equal "en", labels[0].language

    labels = Iqvoc::SimilarTerms.terms_to_labels("de", "forest")
    assert_equal 0, labels.count

    labels = Iqvoc::SimilarTerms.terms_to_labels("en", "foo")
    assert_equal 0, labels.count

    # TODO: test XLLabel and Inflectional variants
  end

end
