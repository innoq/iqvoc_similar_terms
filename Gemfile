source 'https://rubygems.org'

gem 'iqvoc', '~> 4.14.0', github: 'innoq/iqvoc', branch: 'master'

platforms :ruby do
  gem 'pg'
end

group :development do
  gem 'better_errors'
  gem 'web-console'
  gem 'listen'
end

group :development, :test do
  gem 'pry-rails', require: 'pry'
end

group :test do
  gem 'iqvoc_skosxl', '~> 2.11.0', github: 'innoq/iqvoc_skosxl', branch: 'master'
  gem 'iqvoc_compound_forms', '~> 2.11.0', github: 'innoq/iqvoc_compound_forms', branch: 'master'
end
