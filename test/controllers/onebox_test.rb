# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')

class OneBoxTest < ActionController::TestCase

  setup do
    @controller = SimilarTermsController.new

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
  end

  test "XML representation" do
    get :show, :lang => "en", :format => "xml", :terms => "foo"
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

    get :show, :lang => "en", :format => "xml", :terms => "forest"
    assert_response 200
    assert @response.body.include?("<totalResults>2</totalResults>")
    assert @response.body.include?(<<-EOS.strip)
  <MODULE_RESULT>
    <title>similar terms for 'forest'</title>
    EOS
    assert @response.body.include? '<Field name="forest">forest</Field>'
    assert @response.body.include? '<Field name="woods">woods</Field>'
  end

end
