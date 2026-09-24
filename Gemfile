source 'https://rubygems.org'

gem 'iqvoc', '~> 4.16.0', github: 'innoq/iqvoc', branch: 'bootstrap5'

platforms :ruby do
  gem 'pg'
end

group :development do
  gem 'web-console'
end

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ windows ]
end

group :test do
  gem 'iqvoc_skosxl', '~> 2.12.0', github: 'innoq/iqvoc_skosxl', branch: 'bootstrap5'
  gem 'iqvoc_compound_forms', '~> 2.12.0', github: 'innoq/iqvoc_compound_forms', branch: 'bootstrap5'
end
