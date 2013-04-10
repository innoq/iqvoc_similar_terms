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
      concepts = terms_to_concepts(lang, *terms).
          includes(:labelings => [:owner, :target])
      return terms.inject({}) do |memo, term|
        concepts.each do |concept|
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

    def self.terms_to_concepts(lang, *terms)
      concept_ids = terms_to_labels(lang, *terms).includes(:labelings).
          map { |label| label.labelings.map(&:owner_id) }.flatten.uniq
      return Iqvoc::Concept.base_class.where(:id => concept_ids)
    end

    # NB: case-insensitive only when inflectionals are available
    def self.terms_to_labels(lang, *terms)
      if Iqvoc.const_defined?(:Inflectionals)
        raise NotImplementedError # TODO
        # use normalized form for case-insensitivity (and performance)
        hash = Inflectional::Base.normalize(term)
      elsif Iqvoc.const_defined?(:XLLabel)
        return Iqvoc::XLLabel.base_class.where(:language => lang,
            :value => terms.length < 2 ? terms[0] : terms)
      else
        return Iqvoc::Label.base_class.where(:language => lang,
            :value => terms.length < 2 ? terms[0] : terms)
      end
    end

  end
end
