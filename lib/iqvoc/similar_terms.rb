module Iqvoc
  module SimilarTerms # TODO: make language constraints optional

    WEIGHTINGS = { # XXX: hard-coded - should be read from configuration -- XXX: unused/deprecated
      "Labeling::SKOS::PrefLabel"     => 5,
      "Labeling::SKOS::AltLabel"      => 2,
      "Labeling::SKOS::HiddenLabel"   => 1,
      # SKOS-XL
      "Labeling::SKOSXL::PrefLabel"   => 5,
      "Labeling::SKOSXL::AltLabel"    => 2,
      "Labeling::SKOSXL::HiddenLabel" => 1
    }

    # returns an array of label/concepts pairs, sorted descendingly by weighting -- XXX: unused/deprecated
    def self.ranked(lang, *terms) # TODO: rename
      weighted(lang, *terms).
          sort_by { |label, data| label }.
          sort_by { |label, data| data[0] }.
          reverse.
          map { |label, data| [label] + data[1..-1] } # drop weighting
    end

    # returns a hash of label/weighting+concepts pairs -- XXX: unused/deprecated
    def self.weighted(lang, *terms) # TODO: rename
      concepts = terms_to_concepts(lang, *terms).
          includes(:labelings => [:owner, :target]).
          where("labels.language" => lang) # applies language constraint to results
      return terms.inject({}) do |memo, term|
        concepts.each do |concept|
          concept.labelings.each do |ln|
            concept = ln.owner
            label = ln.target
            weight = WEIGHTINGS[ln.class.name]

            memo[label] ||= []
            # weighting
            memo[label][0] ||= 0
            memo[label][0] += weight
            # associated concepts
            memo[label] << concept
            concept.narrower_relations.map { |nr| nr.target.pref_label }.each do |pref_label|
              memo[pref_label] ||= []
              memo[pref_label][0] = 0
              # associated concepts
              memo[pref_label] << concept
              memo[pref_label].uniq!
              #binding.pry
            end
            memo[label].uniq! # XXX: inefficient!? can't easily use Set here though
          end
        end
        memo
      end
    end

    # returns a list of labels, sorted alphabetically
    def self.alphabetical(lang, *terms)
      concepts = terms_to_concepts(lang, *terms).
          includes(:labelings => [:owner, :target]).
          where("labels.language" => lang) # applies language constraint to results
      return concepts.map do |concept|
        concept.labelings.map { |ln| ln.target }
      end.flatten.sort_by { |label| label.value }
    end

    def self.terms_to_concepts(lang, *terms)
      concept_ids = terms_to_labels(lang, *terms).includes(:labelings).
          map { |label| label.labelings.map(&:owner_id) }.flatten.uniq
      return Iqvoc::Concept.base_class.where(:id => concept_ids)
    end

    # NB: case-insensitive only when inflectionals are available
    def self.terms_to_labels(lang, *terms)
      # efficiency enhancement to turn `IN` into `=` queries where possible
      reduce = lambda { |arr| arr.length < 2 ? arr[0] : arr }

      if Iqvoc.const_defined?(:Inflectionals)
        # use normalized form for case-insensitivity (and performance)
        hashes = terms.map { |term| Inflectional::Base.normalize(term) }
        label_ids = Inflectional::Base.select([:label_id]).
            where(:normal_hash => reduce.call(hashes)).map(&:label_id)
        return Iqvoc::XLLabel.base_class.where(:language => lang,
            :id => reduce.call(label_ids))
      elsif Iqvoc.const_defined?(:XLLabel)
        return Iqvoc::XLLabel.base_class.where(:language => lang,
            :value => reduce.call(terms))
      else
        return Iqvoc::Label.base_class.where(:language => lang,
            :value => reduce.call(terms))
      end
    end

  end
end
