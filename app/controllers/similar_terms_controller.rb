# encoding: UTF-8

class SimilarTermsController < ApplicationController

  def show
    authorize! :read, Iqvoc::Concept.base_class

    unless params[:terms]
      head 400
      return
    end

    terms = Iqvoc::InlineDataHelper.parse_inline_values(params[:terms])
    lang = params[:lang]

    head :ok
  end

end
