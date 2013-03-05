# encoding: UTF-8

require 'iqvoc/similar_terms/version'

module IqvocSimilarTerms

  unless Iqvoc.const_defined?(:SimilarTerms) && Iqvoc::SimilarTerms.const_defined?(:Application)
    require File.join(File.dirname(__FILE__), '../config/engine')
  end

  ActiveSupport.on_load(:after_iqvoc_config) do
    require 'iqvoc'
  end

end
