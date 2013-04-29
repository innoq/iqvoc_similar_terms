# encoding: UTF-8

require 'iqvoc/similar_terms' # XXX: should not be necessary!?

class SimilarTermsController < ApplicationController

  def show
    authorize! :read, Iqvoc::Concept.base_class

    unless params[:terms]
      head 400 unless request.format.html? # non-GUI
      return
    end

    @terms = Iqvoc::InlineDataHelper.parse_inline_values(params[:terms])
    lang = params[:lang]


    respond_to do |format|
      format.any(:html, :ttl, :rdf) do
        @results = Iqvoc::SimilarTerms.ranked(lang, *@terms)
      end
      format.text do
        render :text => Iqvoc::SimilarTerms.alphabetical(lang, *@terms).join("\n")
      end
    end
  end

end
