ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

def load_test_data
  SkosImporter.new('test/similar_terms.nt', 'http://localhost:3000/').run
end
