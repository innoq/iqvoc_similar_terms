# encoding: UTF-8

require 'iqvoc/similar_terms' # XXX: should not be necessary!?

class SimilarTermsController < ApplicationController

  def show
    authorize! :read, Iqvoc::Concept.base_class

    unless params[:terms]
      head 400
      return
    end

    @terms = Iqvoc::InlineDataHelper.parse_inline_values(params[:terms])
    lang = params[:lang]

    @results = Iqvoc::SimilarTerms.ranked(lang, *@terms)

    respond_to do |format|
      format.ttl
      format.rdf
    end
  end

end
