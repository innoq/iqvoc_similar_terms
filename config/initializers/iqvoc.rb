Iqvoc.config.register_setting("title", "iQvoc Similar Terms")

Iqvoc.navigation_items.insert(-6, { # in front of search, users, configuration, help and about
  :content => proc { link_to t("txt.views.similar_terms.title"), similar_path },
  :controller => "similar_terms"
})
