Iqvoc.localized_routes << lambda do |routing|
  # XXX: adjective as resource
  routing.get "similar" => "similar_terms#show"
  routing.post "similar" => "similar_terms#query"
end

Rails.application.routes.draw do
  # see above
end
