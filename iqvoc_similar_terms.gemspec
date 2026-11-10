# encoding: UTF-8

$:.push File.expand_path("../lib", __FILE__)
require "iqvoc/similar_terms/version"

Gem::Specification.new do |s|
  s.name        = "iqvoc_similar_terms"
  s.version     = Iqvoc::SimilarTerms::VERSION
  s.platform    = Gem::Platform::RUBY
  s.required_ruby_version = ">= 3.3"
  s.authors     = ["Frederik Dohr", "Robert Glaser", "Till Schulte-Coerne"]
  s.email       = ["robert.glaser@innoq.com"]
  s.homepage    = "https://github.com/innoq/iqvoc_similar_terms"
  s.summary     = "iQvoc similar terms extension"
  s.description = "SimilarTerms extension for iQvoc"
  s.license     = "Apache-2.0"

  s.add_dependency "iqvoc", "~> 4.17.0"

  s.files = `git ls-files -z -- README.md Gemfile Rakefile iqvoc_similar_terms.gemspec app config db lib test`.split("\0")
  s.test_files = s.files.grep(%r{^test/})
  s.require_paths = ["lib"]
end
