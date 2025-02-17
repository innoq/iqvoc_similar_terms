module Iqvoc
  module SimilarTerms # TODO: make language constraints optional

    @@weightings = {
      'Labeling::Skos::PrefLabel'     => 5,
      'Labeling::Skos::AltLabel'      => 2,
      'Labeling::Skos::HiddenLabel'   => 0,
      # SKOS-XL
      'Labeling::Skosxl::PrefLabel'   => 5,
      'Labeling::Skosxl::AltLabel'    => 2,
      'Labeling::Skosxl::HiddenLabel' => 0
    }

    def self.register_weighting(klass_str, value)
      Mutex.new.synchronize do
        @@weightings[klass_str] = value
      end
    end

    def self.weightings
      @@weightings
    end
  end
end
