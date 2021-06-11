module LcRelatorsToCsv
  class Term
    attr_reader :statements
    def initialize(uri, graph)
      @uri = uri
      @graph = graph
      @statements = @graph.by_subject(sub: @uri)
      @mads = RDF::Vocabulary.new('http://www.loc.gov/mads/rdf/v1#')
      @vocabulary = 'MARC Code List for Relators Scheme'
    end

    def name
      @name ||= get_name
    end

    def code
      @code ||= @statements.dup.filter(pred: @mads.code).first[:obj].value
    end

    def alt_names
      @alt_names ||= get_alt_names
    end

    def deprecated?
      type = @statements.dup.filter(pred: RDF.type, obj: @mads.DeprecatedAuthority)
      return false if type.empty?

      true
    end

    def collection
      @collections ||= get_collection
    end

    def description
      @description ||= get_description
    end

    def use_term
      @use_term ||= get_use_term
    end

    def csv_row
      row = [name, description, @uri, code, alt_names, collection, @vocabulary]
      return row unless deprecated?

      row << 1
      row << use_term
      row
    end
    
    private

    def get_use_term
      return '' unless deprecated?

      use = @statements.dup.filter(pred: @mads.useInstead)
      return '' if use.empty?

      use.map(&:obj)
        .map{ |uri| @graph.by_subject_and_predicate(sub: uri, pred: @mads.authoritativeLabel) }
        .flatten
        .map(&:obj)
        .map(&:value)
        .join('|')
    end
    
    def get_collection
      colls = @statements.dup.filter(pred: @mads.isMemberOfMADSCollection)
        .map(&:obj)
        .select{ |coll| relevant_colls.any?(coll) }
      return '' if colls.empty?
      
      mapped = colls.map{ |coll| map_collection_value(coll) }
      return mapped[0] if mapped.length == 1

      select_priority_collection(mapped)
    end

    def get_description
      result = @statements.dup.filter(pred: @mads.definitionNote)
      return '' if result.empty?
      
      result.first[:obj].value
    end
    
    def get_name
      name = deprecated? ? @statements.dup.filter(pred: @mads.deprecatedLabel).first : @statements.dup.filter(pred: @mads.authoritativeLabel).first
      return name[:obj].value unless name.nil?

      puts "#{@uri} - No Name Value?"
    end

    
    def get_alt_names
      hasvar = @statements.dup.filter(pred: @mads.hasVariant).map(&:obj)
      return '' if hasvar.empty?
      
      if made_of_nodes?(hasvar.dup)
        variants = hasvar.map{ |node| @graph.by_subject_and_predicate(sub: node, pred: @mads.variantLabel).map(&:obj) }.flatten
        en_vars = variants.select{ |var| var.language == :en }
        en_vars.map(&:value).sort.join('|')
      else
        puts "#{code} - var length = #{hasvar.length} - var type = #{hasvar.map(&:obj).map(&:class).join(',')}"
      end
    end

    def made_of_nodes?(arr)
      arr.reject!{ |element| element.is_a?(RDF::Node) }
      return false unless arr.empty?
      
      true
    end

    def relevant_colls
      @relevant_colls ||= [
        'http://id.loc.gov/vocabulary/relators/collection_RDAContributor',
        'http://id.loc.gov/vocabulary/relators/collection_RDACreator',
        'http://id.loc.gov/vocabulary/relators/collection_RDAOther',
        'http://id.loc.gov/vocabulary/relators/collection_RDAOwner',
        'http://id.loc.gov/vocabulary/relators/collection_RDAPublisher'
      ].map{ |url| RDF::URI(url) }
    end

    def map_collection_value(uri)
      uri.value.sub('http://id.loc.gov/vocabulary/relators/collection_RDA', '')
    end

    def select_priority_collection(mapped)
      %w[Creator Contributor Other Publisher Owner].each do |pricoll|
        return pricoll if mapped.any?(pricoll)
      end
    end
  end
end
