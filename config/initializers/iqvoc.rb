Iqvoc.config.register_setting("title", "iQvoc Similar Terms")

ActiveSupport.on_load :navigation_services_group_created do
  Iqvoc.navigation_items[-3][:items] << {
    :text  => proc { t("txt.views.similar_terms.title") },
    :href  => proc { similar_path },
    :controller => "similar_terms"
  }
end
