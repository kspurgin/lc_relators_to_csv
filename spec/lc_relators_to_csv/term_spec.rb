RSpec.describe LcRelatorsToCsv::Term do
  let(:graph) { LcRelatorsToCsv::RelatorGraph.new('~/data/lc_relators/vocabularyrelators.nt') }
  let(:uri) { RDF::URI.new("http://id.loc.gov/vocabulary/relators/#{termcode}")}
  let(:term) { described_class.new(uri, graph) }

  describe '#name' do
    context 'active term' do
      let(:termcode) { 'aut' }
      it 'returns value from mads.authoritativeLabel' do
        expect(term.name).to eq('Author')
      end
    end

    context 'deprecated term' do
      let(:termcode) { 'voc' }
      it 'returns value from mads.deprecatedLabel' do
        expect(term.name).to eq('Vocalist')
      end
    end
  end

  describe '#code' do
    let(:termcode) { 'edt' }
    it 'returns value from mads.code' do
      expect(term.code).to eq(termcode)
    end
  end

  describe '#alt_names' do
    context 'none present' do
      let(:termcode) {'ivr'}
      it 'returns empty string' do
        expect(term.alt_names).to eq('')
      end
    end

    context 'one present' do
      let(:termcode) {'spn'}
      it 'value from mads.hasVariant blank node' do
        expect(term.alt_names).to eq('Sponsoring body')
      end
    end

    context 'multiple present' do
      let(:termcode) {'wit'}
      it 'values from mads.hasVariant blank nodes' do
        expect(term.alt_names).to eq('Deponent|Eyewitness|Observer|Onlooker|Testifier')
      end
    end
  end

  describe '#deprecated?' do
    context 'active term' do
      let(:termcode) { 'wdc' }
      it 'returns false' do
        expect(term.deprecated?).to be false
      end
    end

    context 'deprecated term' do
      let(:termcode) { 'clb' }
      it 'returns true' do
        expect(term.deprecated?).to be true
      end
    end
  end

  describe 'description' do
    context 'none present' do
      let(:termcode) {'grt'}
      it 'returns empty string' do
        expect(term.description).to eq('')
      end
    end

    context 'one present' do
      let(:termcode) {'dpt'}
      it 'value from mads.defintionNote' do
        expect(term.description).to eq('A current owner of an item who deposited the item into the custody of another person, family, or organization, while still retaining ownership')
      end
    end
  end

  describe '#use_term' do
    context 'active term' do
      let(:termcode) { 'wdc' }
      it 'returns blank string' do
        expect(term.use_term).to eq('')
      end
    end

    context 'deprecated term' do
      let(:termcode) { 'clb' }
      it 'returns value from mads.useInstead' do
        expect(term.use_term).to eq('Contributor')
      end
    end
  end

  describe '#collection' do
    context 'none present' do
      let(:termcode) {'pat'}
      it 'returns empty string' do
        expect(term.collection).to eq('')
      end
    end

    context 'one present' do
      let(:termcode) {'ato'}
      it 'returns mapped collection name' do
        expect(term.collection).to eq('Other')
      end
    end

    context 'multiple present' do
      let(:termcode) {'cmp'}
      it 'returns mapped name of priority collection ' do
        expect(term.collection).to eq('Creator')
      end
    end
  end
end
