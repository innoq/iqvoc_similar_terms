#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'

Iqvoc::SimilarTerms::Application.load_tasks

require 'bundler'
Bundler::GemHelper.install_tasks

desc "Build gem"
task :build do |t|
  `rm *.gem; gem build *.gemspec`
end

desc "Release gem"
task :release => :build do |t|
  `gem push *.gem`
end
