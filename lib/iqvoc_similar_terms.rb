# encoding: UTF-8

require 'iqvoc/similar_terms'
require 'iqvoc/similar_terms/version'

module IqvocSimilarTerms

  def self.app?
    Iqvoc.const_defined?(:SimilarTerms) && Iqvoc::SimilarTerms.const_defined?(:Application)
  end

  def self.root
    if app?
      Rails.root
    else
      Iqvoc::SimilarTerms::Engine.root
    end
  end

  unless app?
    require File.join(File.dirname(__FILE__), '../config/engine')
  end

  ActiveSupport.on_load(:after_iqvoc_config) do
    require 'iqvoc'
  end

end
