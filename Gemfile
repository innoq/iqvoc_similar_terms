source 'https://rubygems.org'

gem 'iqvoc', '~> 4.15.1', github: 'innoq/iqvoc', branch: :main

platforms :ruby do
  gem 'pg'
end

group :development do
  gem 'web-console'
  gem 'listen'
end

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ windows ]
end

group :test do
  gem 'iqvoc_skosxl', '~> 2.11.3', github: 'innoq/iqvoc_skosxl', branch: :main
  gem 'iqvoc_compound_forms', '~> 2.11.3', github: 'innoq/iqvoc_compound_forms', branch: :main
end
