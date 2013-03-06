module Iqvoc
  module SimilarTerms

    def self.term_to_concepts(term, lang) # TODO: make language optional
      return term_to_labels(term, lang).includes(:labelings => :owner).
          map { |label| label.labelings.map(&:owner) }.flatten.uniq
    end

    # NB: case-insensitive only when inflectionals are available
    def self.term_to_labels(term, lang) # TODO: make language optional
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
