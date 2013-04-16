Iqvoc.localized_routes << lambda do |routing|
  # XXX: adjective as resource
  routing.get "similar" => "similar_terms#show"
end

Rails.application.routes.draw do
  # see configuration (initializer)
end
