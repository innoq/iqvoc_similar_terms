source 'https://rubygems.org'

gem 'iqvoc', '~> 4.8.0', :github => 'innoq/iqvoc'

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
