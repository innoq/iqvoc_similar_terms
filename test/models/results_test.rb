# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')

class ResultsTest < ActiveSupport::TestCase

  setup do
    forest_label = Iqvoc::XLLabel.base_class.create(value: 'forest', language: 'en')
    wood_label = Iqvoc::XLLabel.base_class.create(value: 'woods', language: 'en')
    forest = Iqvoc::Concept.base_class.create(origin: 'forest')
    forest.pref_labels << forest_label
    forest.alt_labels << wood_label
    forest.save

    car_label = Iqvoc::XLLabel.base_class.create(value: 'car', language: 'en')
    auto_label = Iqvoc::XLLabel.base_class.create(value: 'automobile', language: 'en')
    car = Iqvoc::Concept.base_class.create(origin: 'car')
    car.pref_labels << car_label
    car.alt_labels << auto_label
    car.save

    water_label = Iqvoc::XLLabel.base_class.create(value: 'water', language: 'en')
    real_water_label = Iqvoc::XLLabel.base_class.create(value: 'real water', language: 'en')
    water = Iqvoc::Concept.base_class.create(origin: 'water', top_term: true)
    water.pref_labels << water_label
    water.alt_labels << real_water_label
    water.save

    used_water_label = Iqvoc::XLLabel.base_class.create(value: 'used water', language: 'en')
    no_water_label = Iqvoc::XLLabel.base_class.create(value: 'no water', language: 'en')
    used_water = Iqvoc::Concept.base_class.create
    used_water.pref_labels << used_water_label
    used_water.alt_labels << no_water_label
    used_water.save

    RDFAPI.devour used_water, 'skos:broader', water

    new_water_label = Iqvoc::XLLabel.base_class.create(value: 'new water', language: 'en')
    new_water = Iqvoc::Concept.base_class.create
    new_water.pref_labels << new_water_label
    new_water.save

    RDFAPI.devour new_water, 'skos:broader', water

    water.narrower_relations.first.target_id = used_water.id
    water.narrower_relations.second.target_id = new_water.id
  end

  test "ranked results" do
    results = Iqvoc::SimilarTerms.ranked("en", "forest")
    assert_equal 2, results.length
    assert_equal Iqvoc::XLLabel.base_class, results[0][0].class
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
      assert_equal Iqvoc::XLLabel.base_class, label.class
      assert_equal 2, data.length
      assert_equal expected[label.value], data[0]
      assert_equal Iqvoc::Concept.base_class, data[1].class
    end
  end

  test "inclusion of pref labels of sub concepts" do
    results = Iqvoc::SimilarTerms.weighted("en", "water")
    assert_equal 4, results.length
    assert_equal "water", results.keys.first.value
    assert_equal 5, results[results.keys.first][0]
    assert_equal "used water", results.keys.second.value
    assert_equal 0, results[results.keys.second][0]
    assert_equal "new water", results.keys.third.value
    assert_equal 0, results[results.keys.third][0]
    assert_equal "real water", results.keys.fourth.value
    assert_equal 2, results[results.keys.fourth][0]
  end

  test "no results" do
    results = Iqvoc::SimilarTerms.weighted("de", "water")
    assert_equal 0, results.length
  end

end
