source 'https://rubygems.org'

gem 'iqvoc', '~> 4.17.0', github: 'innoq/iqvoc'

platforms :ruby do
  gem 'pg'
end

group :development do
  gem 'web-console'
end

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ]
end

group :test do
  gem 'iqvoc_skosxl', '~> 2.13.0', github: 'innoq/iqvoc_skosxl'
  gem 'iqvoc_compound_forms', '~> 2.13.0', github: 'innoq/iqvoc_compound_forms'
end
