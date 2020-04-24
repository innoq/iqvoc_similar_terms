source 'https://rubygems.org'

gem 'iqvoc', '~> 4.12', :github => 'innoq/iqvoc', branch: 'rails-v5'

platforms :ruby do
  gem 'pg', '~> 0.21.0'
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
  gem 'iqvoc_skosxl', '~> 2.9.0', git: 'https://github.com/innoq/iqvoc_skosxl', branch: 'rails-v5'
  gem 'iqvoc_compound_forms', '~> 2.9.0', git: 'https://github.com/innoq/iqvoc_compound_forms', branch: 'rails-v5'
end
