module Iqvoc
  module SimilarTerms # TODO: make language constraints optional

    WEIGHTINGS = { # XXX: hard-coded - should be read from configuration
      "Labeling::SKOS::PrefLabel"   => 5,
      "Labeling::SKOS::AltLabel"    => 2,
      "Labeling::SKOS::HiddenLabel" => 1
    }

    # returns an array of label/concepts pairs, sorted descendingly by weighting
    def self.ranked(lang, *terms) # TODO: rename
      weighted(lang, *terms).sort_by { |label, data| data[0] }.reverse.
          map { |label, data| [label] + data[1..-1] } # drop weighting
    end

    # returns a hash of label/weighting+concepts pairs
    def self.weighted(lang, *terms) # TODO: rename
      return terms.inject({}) do |memo, term|
        term_to_concepts(term, lang).each do |concept|
          concept.labelings.each do |ln|
            concept = ln.owner
            label = ln.target # XXX: not loaded eagerly
            weight = WEIGHTINGS[ln.class.name]

            memo[label] ||= []
            # weighting
            memo[label][0] ||= 0
            memo[label][0] += weight
            # associated concepts
            memo[label] << concept
          end
        end
        memo
      end
    end

    def self.term_to_concepts(term, lang)
      return term_to_labels(term, lang).includes(:labelings => :owner).
          map { |label| label.labelings.map(&:owner) }.flatten.uniq
    end

    # NB: case-insensitive only when inflectionals are available
    def self.term_to_labels(term, lang)
      if Iqvoc.const_defined?(:Inflectionals)
        raise NotImplementedError # TODO
        # use normalized form for case-insensitivity (and performance)
        hash = Inflectional::Base.normalize(term)
      elsif Iqvoc.const_defined?(:XLLabel)
        return Iqvoc::XLLabel.base_class.where(:value => term, :language => lang)
      else
        return Iqvoc::Label.base_class.where(:value => term, :language => lang)
      end
    end

  end
end
