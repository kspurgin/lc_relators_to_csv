RSpec.describe LcRelatorsToCsv::RelatorGraph do
  let(:path) { '~/data/lc_relators/vocabularyrelators.nt' }
  let(:nt) { described_class.new(path) }

  describe '#terms' do
    it 'returns array of Terms' do
      terms = nt.terms
      expect(terms.first).to be_a(LcRelatorsToCsv::Term)
    end
  end

  describe '#collections' do
    it 'returns array of uris for MADS Collections defined for vocabulary' do
      colls = nt.collections
      ex1 = RDF::URI.new('http://id.loc.gov/vocabulary/relators/collection_RDA')
      ex2 = RDF::URI.new('http://id.loc.gov/vocabulary/relators/collection_RDACreator')
      result = colls.any?(ex1) && colls.any?(ex2)
      expect(result).to be true
    end
  end
end
