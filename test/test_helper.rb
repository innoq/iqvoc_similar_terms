ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

def create_compound_form_label(compound_label_hash)
  compound_label_hash.each do |term, components|
    label = Iqvoc::XLLabel.base_class.create!(
      value: term,
      language: Iqvoc::Concept.pref_labeling_languages.first,
      published_at: 2.days.ago)

    label.compound_forms.create!(compound_form_contents: components.each_with_index.map { |cterm, i|
      clabel = Iqvoc::XLLabel.base_class.create!(value: cterm,
                                                 language: Iqvoc::Concept.pref_labeling_languages.first,
                                                 published_at: 2.days.ago)
      CompoundForm::Content::Base.new(:label => clabel, :order => i)
    })
  end
end
