Iqvoc.config.register_setting("title", "iQvoc Similar Terms")

Iqvoc::Navigation.add_grouped({
  :text  => proc { t("txt.views.similar_terms.title") },
  :href  => proc { similar_path },
  :controller => "similar_terms"
}, -3)
