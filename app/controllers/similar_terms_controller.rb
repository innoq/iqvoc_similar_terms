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
      format.html do
        @results = Iqvoc::SimilarTerms.ranked(lang, *@terms)
      end
      format.ttl do
        @results = Iqvoc::SimilarTerms.alphabetical(lang, *@terms)

        # manually generating Turtle here to allow users to process the data
        # without requiring an RDF parser (not using IqRdf because it doesn't
        # appear to support this format and we want to avoid subtle changes in
        # the serialization).
        query = url_for(request.query_parameters.
            merge(:only_path => false, :anchor => ""))
        literals = @results.
            map { |label| IqRdf::Literal.new label.value, label.language }.
            join(", ")
        render :text => <<-rdf.strip
@prefix skos: <http://www.w3.org/2004/02/skos/core#>.
@prefix query: <#{query}>.

query:top skos:altLabel #{literals}.
        rdf
      end
    end
  end

end
