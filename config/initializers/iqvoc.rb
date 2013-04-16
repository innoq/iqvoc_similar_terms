Iqvoc.config.register_setting("title", "iQvoc Similar Terms")

Iqvoc.navigation_items.insert(-6, { # in front of search, users, configuration, help and about
  :content => proc { link_to "Similar Terms", similar_path }, # TODO: i18n
  :controller => "similar_terms"
})
