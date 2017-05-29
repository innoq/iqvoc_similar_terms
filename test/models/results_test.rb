# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')

class ResultsTest < ActiveSupport::TestCase

  setup do
    forest = RDFAPI.devour("forest", "a", "skos:Concept")
    RDFAPI.devour(forest, "skos:prefLabel", '"forest"@en')
    RDFAPI.devour(forest, "skos:altLabel", '"woods"@en')
    forest.save

    car = RDFAPI.devour("car", "a", "skos:Concept")
    RDFAPI.devour(car, "skos:prefLabel", '"car"@en')
    RDFAPI.devour(car, "skos:altLabel", '"automobile"@en')
    car.save

    water = Concept::SKOS::Base.new(top_term: true).tap do |c|
      RDFAPI.devour c, 'skos:prefLabel', '"Water"@en'
      RDFAPI.devour c, 'skos:altLabel', '"Real Water"@en'
      c.save
    end

    Concept::SKOS::Base.new.tap do |c|
      RDFAPI.devour c, 'skos:prefLabel', '"Used Water"@en'
      RDFAPI.devour c, 'skos:altLabel', '"No Water"@en'
      RDFAPI.devour c, 'skos:broader', water
      c.save
    end

    Concept::SKOS::Base.new.tap do |c|
      RDFAPI.devour c, 'skos:prefLabel', '"New Water"@en'
      RDFAPI.devour c, 'skos:broader', water
      c.save
    end
  end

  test "ranked results" do
    results = Iqvoc::SimilarTerms.ranked("en", "forest")
    assert_equal 2, results.length
    assert_equal Iqvoc::Label.base_class, results[0][0].class
    assert_equal "forest", results[0][0].value
    assert_equal "forest", results[0][1].origin
    assert_equal "woods", results[1][0].value
    assert_equal "forest", results[1][1].origin

    results = Iqvoc::SimilarTerms.ranked("en", "woods", "car")
    assert_equal 4, results.length
    assert_equal "forest", results[0][0].value
    assert_equal "forest", results[0][1].origin
    assert_equal "car", results[1][0].value
    assert_equal "car", results[1][1].origin
    assert_equal "woods", results[2][0].value
    assert_equal "forest", results[2][1].origin
    assert_equal "automobile", results[3][0].value
    assert_equal "car", results[3][1].origin
    assert_equal results[0].length, results[0].uniq.length
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

  test "inclusion of pref labels of sub concepts" do
    results = Iqvoc::SimilarTerms.weighted("en", "Water")
    assert_equal 4, results.length
    assert_equal "Water", results.keys.first.value
    assert_equal 5, results[results.keys.first][0]
    assert_equal "Used Water", results.keys.second.value
    assert_equal 0, results[results.keys.second][0]
    assert_equal "New Water", results.keys.third.value
    assert_equal 0, results[results.keys.third][0]
    assert_equal "Real Water", results.keys.fourth.value
    assert_equal 2, results[results.keys.fourth][0]
  end

  test "no results" do
    results = Iqvoc::SimilarTerms.weighted("de", "Water")
    assert_equal 0, results.length
  end

end
