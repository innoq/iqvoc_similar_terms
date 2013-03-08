Iqvoc.localized_routes << lambda do |routing| # XXX: belongs into routes.rb!?
  routing.get "similar" => "similar_terms#show" # XXX: adjective as resource
end

Iqvoc.config.register_setting("title", "iQvoc Similar Terms")
