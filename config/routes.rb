Rails.application.routes.draw do
  scope ":lang", :constraints => Iqvoc.routing_constraint do
    get "similar/new" => "similar_terms#new", as: 'new_similar'
    get "similar" => "similar_terms#create"
  end
end
