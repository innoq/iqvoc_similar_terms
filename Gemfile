source 'http://rubygems.org'

gem 'iqvoc'
gem 'iqvoc_skosxl', :git => 'git://github.com/innoq/iqvoc_skosxl.git'
gem 'iqvoc_inflectionals'
gem 'iqvoc_similar_terms'

group :development, :test do
  gem 'pry-rails'
  gem 'pry-debugger'

  platforms :ruby do
    gem 'sqlite3'
  end
end

group :staging do
  gem 'pg'
  gem 'uglifier'
end
