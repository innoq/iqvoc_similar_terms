# encoding: UTF-8

$:.push File.expand_path("../lib", __FILE__)
require "iqvoc/similar_terms/version"

Gem::Specification.new do |s|
  s.name        = "iqvoc_similar_terms"
  s.version     = Iqvoc::SimilarTerms::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Frederik Dohr", "Robert Glaser", "Till Schulte-Coerne"]
  s.email       = ["robert.glaser@innoq.com"]
  s.homepage    = "" # TODO
  s.summary     = "" # TODO
  s.description = "" # TODO

  s.rubyforge_project = "iqvoc_similar_terms"

  s.add_dependency "iqvoc", "~> 4.3.0"

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]
end
