# encoding: UTF-8

class SimilarTermsController < ApplicationController
  resource_description do
    name 'Similar concepts'
  end

  api :GET, ':lang/similar', <<-DOC
    Returns labels which are semantically (not orthographically) similar,
    as determined by concept relations.
  DOC
  formats [:html, :ttl, :rdf, :xml, :json]
  param :terms, String, :required => true, :desc => <<-DOC
    One or more terms (comma-separated, CSV-style) to be processed.
  DOC
  example <<-DOC
    GET /de/similar.ttl?terms=wald,baum

    # omitted namespace definitions
    query:top skos:altLabel "Dünenwald"@de;
              skos:altLabel "Baumart"@de.
  DOC

  def create
    authorize! :read, Iqvoc::Concept.base_class

    @terms = InlineDataHelper.parse_inline_values(similar_terms_params)
    lang = params[:lang]

    respond_to do |format|
      format.html do
        @results = Services::SimilarTermsService.ranked(lang, *@terms)
        render :show
      end
      format.any(:rdf, :ttl, :nt, :xml) do
        @results = Services::SimilarTermsService.alphabetical(lang, *@terms)
        render :show
      end
      format.json {
        results = Services::SimilarTermsService.alphabetical(lang, *@terms)
        render json: {
          "url": request.original_url,
          "total_results": results.length,
          "results": results.map {|c| c.value }
        }.to_json
      }
    end
  end

  def new
  end

  private

  def similar_terms_params
    params.require(:terms)
  end
end
