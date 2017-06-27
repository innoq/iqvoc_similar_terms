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
            memo[label] << concept unless memo[label].include? concept
          end
        end

        find_related_and_narrower_concepts(concepts, lang, *terms).each do |c|
          memo[c.pref_label] ||= []
          # weighting
          memo[c.pref_label][0] ||= 0
          memo[c.pref_label][0] += 1
          # associated concepts
          memo[c.pref_label] << c unless memo[c.pref_label].include? c
        end

        memo
      end
    end

    # returns a list of labels, sorted alphabetically
    def self.alphabetical(lang, *terms)
      concepts = terms_to_concepts(lang, *terms)
                 .includes(:labelings => [:owner, :target])
                 .where('labels.language' => lang) # applies language constraint to results

      results = concepts.map { |c| c.labelings.map { |ln| ln.target } }
      results << find_related_and_narrower_concepts(concepts, lang, *terms).map { |c| c.pref_labels }

      results.flatten.sort_by { |l| l.value }
    end

    def self.terms_to_concepts(lang, *terms)
      concept_ids = terms_to_labels(lang, *terms)
                    .includes(:labelings)
                    .map { |label| label.labelings.map(&:owner_id) }.flatten.uniq

      return Iqvoc::Concept.base_class.published.where(id: concept_ids)
    end

    def self.find_related_and_narrower_concepts concepts, lang, *terms
      results = []
      concepts.each do |c|
        results << c.narrower_relations.published.map(&:target_id)
        results << c.concept_relation_skos_relateds.published.map(&:target_id)
      end

      # FIXME!! zu wenig ergebnisse fuer dienst: alt_labels nicht mehr
      # evaluate only if iqvoc_compound_forms engine is loaded
      if Iqvoc.const_defined?(:CompoundForms) && results.empty?
        terms.each do |term|
          label = if Iqvoc.const_defined?(:Inflectionals)
                    hash = Inflectional::Base.normalize(term)
                    label_id = Inflectional::Base.select([:label_id])
                                                 .where(:normal_hash => hash)
                                                 .map(&:label_id)
                                                 .first

                    Iqvoc::XLLabel.base_class.where(:language => lang, :id => label_id).first
                  else
                    Iqvoc::XLLabel.base_class.where('LOWER(value) = ?', term.downcase).first
                  end

          results << label.compound_in.map { |ci| ci.concepts.map { |c| c.id } } if label.present?
        end
      end
      Iqvoc::Concept.base_class.where(id: results.flatten.uniq)
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
        return Iqvoc::XLLabel.base_class
                             .where(language: lang)
                             .where('LOWER(value) IN (?)', terms.map(&:downcase))
      else
        return Iqvoc::Label.base_class
                           .where(language: lang)
                           .where('LOWER(value) IN (?)', terms.map(&:downcase))
      end
    end

  end
end
