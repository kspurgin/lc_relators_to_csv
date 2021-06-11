module LcRelatorsToCsv
  class RelatorGraph
    def initialize(path)
      @graph = RDF::Graph.load(File.expand_path(path))
      @mads = RDF::Vocabulary.new('http://www.loc.gov/mads/rdf/v1#')
    end

    def graph
      @graph
    end

    def terms
      @terms ||= term_uris
    end

    def collections
      @collections ||= collection_uris
    end

    def by_predicate_and_object(pred:, obj:)
      RDF::Query.execute(graph){ pattern [:sub, pred, obj] }
    end

    def by_subject(sub:)
      RDF::Query.execute(graph){ pattern [sub, :pred, :obj] }
    end

    def by_subject_and_predicate(sub:, pred:)
      RDF::Query.execute(graph){ pattern [sub, pred, :obj] }
    end

    private

    def collection_uris
      by_predicate_and_object(pred: RDF.type, obj: @mads.MADSCollection).map{ |solution| solution[:sub] }
    end
    
    def term_uris
      active = by_predicate_and_object(pred: RDF.type, obj: @mads.Authority).map{ |solution| solution[:sub] }
      deprecated = by_predicate_and_object(pred: RDF.type, obj: @mads.DeprecatedAuthority).map{ |solution| solution[:sub] }
      uris = active + deprecated
      uris.map{ |uri| LcRelatorsToCsv::Term.new(uri, self) }
    end
  end
end
