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

    lang = params[:lang]
    options = {
      synonyms_only: %w[1 true].include?(params[:synonyms_only]),
      similar_only: %w[1 true].include?(params[:similar_only]),
    }

    begin
      @terms = InlineDataHelper.parse_inline_values(similar_terms_params)

      respond_to do |format|
        format.html do
          @results = Services::SimilarTermsService.ranked(lang, options, *@terms)
          render :show
        end
        format.any(:rdf, :ttl, :nt, :xml) do
          @results = Services::SimilarTermsService.alphabetical(lang, options, *@terms)
          render :show
        end
        format.json do
          results = Services::SimilarTermsService.alphabetical(lang, options, *@terms)
          render json: create_json_response(results.map { |c| c.value })
        end
      end

    rescue CSV::MalformedCSVError => e
      respond_to do |format|
        format.html do
          flash[:error] = I18n.t('txt.controllers.similar_terms.parsing_error')
          redirect_to new_similar_url
        end
        format.any(:rdf, :ttl, :nt, :xml) do
          @terms = []
          @results = []
          render :show
        end
        format.json do
          render json: create_json_response([])
        end
      end
    end
  end

  def new
  end

  private

  def create_json_response(results)
    {
      "url": request.original_url,
      "total_results": results.length,
      "results": results
    }.to_json
  end

  def similar_terms_params
    params.require(:terms)
  end
end
