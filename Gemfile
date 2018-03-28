source 'https://rubygems.org'

gem 'iqvoc', '~> 4.12', :github => 'innoq/iqvoc', branch: :master

group :development, :test do
  gem 'pry-rails'

  platforms :ruby do
    gem 'mysql2'
    gem 'sqlite3'
    gem 'hirb-unicode'
    gem 'cane'
  end
  platforms :jruby do
    gem 'activerecord-jdbcsqlite3-adapter'
    gem 'activerecord-jdbcmysql-adapter'
  end
end

group :test do
  gem 'iqvoc_skosxl', '~> 2.9.0', git: 'https://github.com/innoq/iqvoc_skosxl', branch: 'master'
  gem 'iqvoc_compound_forms', '~> 2.9.0', git: 'https://github.com/innoq/iqvoc_compound_forms', branch: 'master'
end
