require 'iqvoc/environments/development'

if Iqvoc::SimilarTerms.const_defined?(:Application)
  Iqvoc::SimilarTerms::Application.configure do
    # Settings specified here will take precedence over those in config/environment.rb
    Iqvoc::Environments.setup_development(config)
  end
end
