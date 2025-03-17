module Services
  module SimilarTermsService # TODO: make language constraints optional

    @@weightings = Iqvoc::SimilarTerms.weightings

    # returns an array of label/concepts pairs, sorted descendingly by weighting -- XXX: unused/deprecated
    # TODO: rename
    def self.ranked(lang, options, *terms)
      weighted(lang, options, *terms).sort_by { |label, _data| label }
                            .sort_by { |_label, data| data[0] }
                            .reverse
                            .map { |label, data| [label] + data[1..-1] } # drop weighting
    end

    # returns a list of labels, sorted alphabetically
    def self.alphabetical(lang, options, *terms)
      results = []
      concepts = base_query(lang, *terms)

      unless options[:similar_only]
        results.concat(concepts.map { |c| c.labelings.map { |ln| ln.target } })
      end

      unless options[:synonyms_only]
        results.concat(find_related_and_narrower_concepts(concepts, lang, *terms).map { |c| c.pref_labels })
      end

      results.flatten.sort_by { |l| l.value }
    end

    def self.base_query(lang, *terms)
      # FIXME: move to initializer to run on start/boot. Could be a problem with intializer load
      # order of host app because further_labeling classes are initialised after this check
      Iqvoc::Concept.labeling_class_names.each do |klass_name, langs|
        unless @@weightings.keys.include? klass_name
          raise "#{klass_name} has no registered weighting. Please configure one using Iqvoc::SimilarTerms.register_weighting('MyLabelingClass', 1.0)"
        end
      end

      # use only labelings with weighting > 0
      used_weightings = @@weightings.select { |klass_name, weight| weight > 0 }.keys
      terms_to_concepts(lang, *terms)
        .includes(:labelings => [:owner, :target])
        .where('labels.language' => lang)
        .where('labelings.type IN (?)', used_weightings)
    end

    # returns a hash of label/weighting+concepts pairs -- XXX: unused/deprecated
    def self.weighted(lang, options, *terms) # TODO: rename
      concepts = base_query(lang, *terms)

      return terms.inject({}) do |memo, term|
        unless options[:similar_only]
          concepts.each do |concept|
            concept.labelings.each do |ln|
              concept = ln.owner
              label = ln.target
              weight = @@weightings[ln.class.name]

              memo[label] ||= []
              # weighting
              memo[label][0] ||= 0
              memo[label][0] += weight
              # associated concepts
              memo[label] << concept unless memo[label].include? concept
            end
          end
        end

        unless options[:synonyms_only]
          find_related_and_narrower_concepts(concepts, lang, *terms).each do |c|
            memo[c.pref_label] ||= []
            # weighting
            memo[c.pref_label][0] ||= 0
            memo[c.pref_label][0] += 1
            # associated concepts
            memo[c.pref_label] << c unless memo[c.pref_label].include? c
          end
        end

        memo
      end
    end

    def self.terms_to_concepts(lang, *terms)
      concept_ids = terms_to_labels(lang, *terms)
                    .includes(:labelings)
                    .map { |label| label.labelings.map(&:owner_id) }.flatten.uniq

      return Iqvoc::Concept.base_class.published.where(id: concept_ids)
    end

    def self.find_related_and_narrower_concepts(concepts, lang, *terms)
      results = []
      concepts.each do |c|
        results << c.narrower_relations.published.map(&:target_id)
        results << c.concept_relation_skos_relateds.published.map(&:target_id)
      end

      # evaluate only if iqvoc_compound_forms engine is loaded
      if Iqvoc.const_defined?(:CompoundForms) && results.empty?
        terms.each do |term|
          label = if Iqvoc.const_defined?(:Inflectionals)
                    hash = Inflectional::Base.normalize(term)
                    label_id = Inflectional::Base.select([:label_id])
                                                 .where(:normal_hash => hash)
                                                 .map(&:label_id)
                                                 .first

                    Iqvoc::Xllabel.base_class.where(:language => lang, :id => label_id).first
                  else
                    Iqvoc::Xllabel.base_class.where('LOWER(value) = ?', term.downcase).first
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

        return Iqvoc::Xllabel.base_class.where(language: lang, id: reduce.call(label_ids))
      elsif Iqvoc.const_defined?(:Xllabel)
        return Iqvoc::Xllabel.base_class
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
