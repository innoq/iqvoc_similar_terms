module Iqvoc
  module SimilarTerms # TODO: make language constraints optional

    WEIGHTINGS = {
      # XXX: hard-coded - should be read from configuration -- XXX: unused/deprecated
      'Labeling::SKOS::PrefLabel'     => 5,
      'Labeling::SKOS::AltLabel'      => 2,
      'Labeling::SKOS::HiddenLabel'   => 1,
      # SKOS-XL
      'Labeling::SKOSXL::PrefLabel'   => 5,
      'Labeling::SKOSXL::AltLabel'    => 2,
      'Labeling::SKOSXL::HiddenLabel' => 1
    }

    # returns an array of label/concepts pairs, sorted descendingly by weighting -- XXX: unused/deprecated
    # TODO: rename
    def self.ranked(lang, *terms)
      weighted(lang, *terms).sort_by { |label, _data| label }
                            .sort_by { |_label, data| data[0] }
                            .reverse
                            .map { |label, data| [label] + data[1..-1] } # drop weighting
    end

    # returns a hash of label/weighting+concepts pairs -- XXX: unused/deprecated
    def self.weighted(lang, *terms) # TODO: rename
      concepts = terms_to_concepts(lang, *terms)
                 .includes(:labelings => [:owner, :target])
                 .where('labels.language' => lang) # applies language constraint to results

      return terms.inject({}) do |memo, term|
        concepts.published.each do |concept|
          concept.labelings.each do |ln|
            concept = ln.owner
            label = ln.target
            weight = WEIGHTINGS[ln.class.name]

            memo[label] ||= []
            # weighting
            memo[label][0] ||= 0
            memo[label][0] += weight
            # associated concepts
            memo[label] << concept unless memo[label].include? concept

            concept.narrower_relations.published.map { |nr| nr.target.pref_label }.each do |pref_label|
              memo[pref_label] ||= []
              memo[pref_label][0] ||= 0
              memo[pref_label][0] += 0
              # associated concepts
              pref_label.concepts.published.each do |c|
                memo[pref_label] << c unless memo[pref_label].include? c
              end
            end
          end
        end

        # evaluate only if iqvoc_compound_forms engine is loaded
        if Iqvoc.const_defined?(:CompoundForms)
          label = Iqvoc::XLLabel.base_class.find_by(value: term)
          if memo.empty? && label.present?
            label.compound_in.each do |compound_in|
              memo[compound_in] ||= []
              memo[compound_in][0] ||= 0
              memo[compound_in][0] += 0
              compound_in.concepts.published.each do |concept|
                memo[compound_in] << concept unless memo[compound_in].include? concept
              end
            end
          end
        end
        memo
      end
    end

    # returns a list of labels, sorted alphabetically
    def self.alphabetical(lang, *terms)
      concepts = terms_to_concepts(lang, *terms)
                 .includes(:labelings => [:owner, :target])
                 .where('labels.language' => lang) # applies language constraint to results

      return concepts.map { |concept| concept.labelings.map(&:target) }
                     .flatten.sort_by(&:value)
    end

    def self.terms_to_concepts(lang, *terms)
      concept_ids = terms_to_labels(lang, *terms)
                    .includes(:labelings)
                    .map { |label| label.labelings.map(&:owner_id) }
                    .flatten.uniq

      return Iqvoc::Concept.base_class.where(id: concept_ids)
    end

    # NB: case-insensitive only when inflectionals are available
    def self.terms_to_labels(lang, *terms)
      # efficiency enhancement to turn `IN` into `=` queries where possible
      reduce = lambda { |arr| arr.length < 2 ? arr[0] : arr }

      if Iqvoc.const_defined?(:Inflectionals)
        # use normalized form for case-insensitivity (and performance)
        hashes = terms.map { |term| Inflectional::Base.normalize(term) }
        label_ids = Inflectional::Base.select([:label_id])
                                      .where(normal_hash: reduce.call(hashes))
                                      .map(&:label_id)

        return Iqvoc::XLLabel.base_class.where(language: lang, id: reduce.call(label_ids))
      elsif Iqvoc.const_defined?(:XLLabel)
        return Iqvoc::XLLabel.base_class.where(language: lang, value: reduce.call(terms))
      else
        return Iqvoc::Label.base_class.where(language: lang, value: reduce.call(terms))
      end
    end

  end
end
