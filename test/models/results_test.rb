# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')

class ResultsTest < ActiveSupport::TestCase

  setup do
    load_test_data
    SkosImporter.new('test/concept_test.nt', 'http://localhost:3000/').run
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

  test "compound returns" do
    SkosImporter.new('test/compound_forms.nt', 'http://hobbies.com/').run
    results = Iqvoc::SimilarTerms.weighted("de", "Computer")
    assert_equal 1, results.length
    assert_equal "Computer programming", results.keys.first.value
    assert_equal 0, results[results.keys.first][0]
  end

end
