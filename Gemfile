source 'https://rubygems.org'

gem 'iqvoc', '~> 4.13', github: 'innoq/iqvoc', branch: 'rails-6'

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
  gem 'iqvoc_skosxl', '~> 2.10.0', git: 'https://github.com/innoq/iqvoc_skosxl', branch: 'rails-6'
  gem 'iqvoc_compound_forms', '~> 2.10.0', git: 'https://github.com/innoq/iqvoc_compound_forms', branch: 'rails-6'
end
