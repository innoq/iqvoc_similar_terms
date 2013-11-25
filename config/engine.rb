require 'rails'

module Iqvoc
  module SimilarTerms

    class Engine < Rails::Engine
      paths["lib/tasks"] << "lib/engine_tasks"

      initializer "iqvoc_similar_terms.load_migrations" do |app|
        app.config.paths['db/migrate'].concat(Iqvoc::SimilarTerms::Engine.paths['db/migrate'].existent)
      end
    end

  end
end
