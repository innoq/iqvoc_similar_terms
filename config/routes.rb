Rails.application.routes.draw do
  scope ":lang", :constraints => Iqvoc.routing_constraint do
    get "similar" => "similar_terms#show"
    post "similar" => "similar_terms#query"
  end
end
