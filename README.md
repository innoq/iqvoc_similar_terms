[![Build Status](https://travis-ci.org/innoq/iqvoc_similar_terms.svg?branch=master)](https://travis-ci.org/innoq/iqvoc_similar_terms)

Similar terms for iQvoc

Getting Started
===============

1. Initialize database:

        $ bundle exec rake db:create
        $ bundle exec rake db:migrate iqvoc:db:seed_all

Extensions
==========

In addition to regular SKOS, Similar Terms supports
[SKOS-XL](https://github.com/innoq/iqvoc_skosxl) and
[Inflectionals](https://github.com/innoq/iqvoc_inflectionals) - the latter
provides case-insensitive lookups.

See the respective branches for application templates using those extensions.
