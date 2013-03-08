# encoding: UTF-8

class SimilarTermsController < ApplicationController

  def show
    authorize! :read, Iqvoc::Concept.base_class

    head :ok
  end

end
