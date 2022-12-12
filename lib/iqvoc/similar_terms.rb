module Iqvoc
  module SimilarTerms # TODO: make language constraints optional

    @@weightings = {
      'Labeling::SKOS::PrefLabel'     => 5,
      'Labeling::SKOS::AltLabel'      => 2,
      'Labeling::SKOS::HiddenLabel'   => 0,
      # SKOS-XL
      'Labeling::SKOSXL::PrefLabel'   => 5,
      'Labeling::SKOSXL::AltLabel'    => 2,
      'Labeling::SKOSXL::HiddenLabel' => 0
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
