# encoding: UTF-8

class SimilarTermsController < ApplicationController
  resource_description do
    name 'Similar concepts'
  end

  api :GET, ':lang/similar', <<-DOC
    Returns labels which are semantically (not orthographically) similar,
    as determined by concept relations.
  DOC
  formats [:html, :ttl, :rdf]
  param :terms, String, :required => true, :desc => <<-DOC
    One or more terms (comma-separated, CSV-style) to be processed.
  DOC
  example <<-DOC
    GET /de/similar.ttl?terms=wald,baum

    # omitted namespace definitions
    query:top skos:altLabel "Dünenwald"@de;
              skos:altLabel "Baumart"@de.
  DOC

  def show
    authorize! :read, Iqvoc::Concept.base_class

    unless params[:terms]
      head 400 unless request.format.html? # non-GUI
      return
    end

    @terms = InlineDataHelper.parse_inline_values(params[:terms])
    lang = params[:lang]

    respond_to do |format|
      format.html do
        @results = Iqvoc::SimilarTerms.ranked(lang, *@terms)
      end
      format.any(:rdf, :ttl, :xml) do
        @results = Iqvoc::SimilarTerms.alphabetical(lang, *@terms)
      end
    end
  end

end
