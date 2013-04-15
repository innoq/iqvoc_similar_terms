# encoding: UTF-8

# Be sure to restart your server when you modify this file.

if Iqvoc::SimilarTerms.const_defined?(:Application)

  # Your secret key for verifying the integrity of signed cookies.
  # If you change this key, all old signed cookies will become invalid!
  # Make sure the secret is at least 30 characters and all random,
  # no regular words or you'll be exposed to dictionary attacks.

  # Run `rake secret` and uncomment the following line
  # Replace the secret-placeholder with your generated token
  Iqvoc::SimilarTerms::Application.config.secret_token = "a181e020c0c0c8ad14f8af0806e1684c9d5014efabaad189c1e606c5154880d0703fc14dbbdf4557518b3b576c62a2766ca9e43a8daf263dfa95c5b7466ab151"

end
