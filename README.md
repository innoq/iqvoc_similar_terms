Similar Terms for iQvoc


Getting Started
===============

1. Initialize database:

    $ bundle exec rake db:create
    $ bundle exec rake db:migrate iqvoc:db:seed_all

2. Generate secret token:

    $ rake iqvoc:setup:generate_secret_token
