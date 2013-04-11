Similar Terms for iQvoc


Getting Started
===============

1. Initialize database:

    $ bundle exec rake db:create
    $ bundle exec rake db:migrate iqvoc:db:seed_all

2. Generate secret token:

    $ rake iqvoc:setup:generate_secret_token


Extensions
==========

In addition to regular SKOS, Similar Terms supports
[SKOS-XL](https://github.com/innoq/iqvoc_skosxl) and
[Inflectionals](https://github.com/innoq/iqvoc_inflectionals) - the latter
provides case-insensitive lookups.
