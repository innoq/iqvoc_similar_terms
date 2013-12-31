Apipie.configure do |config|
  config.api_controllers_matcher += [
    "#{IqvocSimilarTerms.root}/app/controllers/*.rb"
  ]
end
