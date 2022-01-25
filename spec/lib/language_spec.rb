require 'spec_helper'

RSpec.describe 'Mods <language> Element' do
  let(:iso639_2b_code_ln) do
    mods_record("<language><languageTerm authority='iso639-2b' type='code'>fre</languageTerm></language>")
  end

  let(:mult_terms) do
    mods_record(<<-XML)
      <language>
        <languageTerm authority='iso639-2b' type='code'>spa</languageTerm>
        <languageTerm authority='iso639-2b' type='text'>Spanish</languageTerm>
        <languageTerm authority='iso639-2b' type='code'>dut</languageTerm>
        <languageTerm authority='iso639-2b' type='text'>Dutch</languageTerm>
      </language>
    XML
  end

  let(:mult_codes) do
    mods_record(<<-XML)
      <language>
        <languageTerm authority='iso639-2b' type='code'>per ara, dut</languageTerm>
      </language>
    XML
  end

  describe '#languages' do
    it 'translates iso639-2b codes to English' do
      expect(iso639_2b_code_ln.languages).to eq(['French'])
      expect(mult_terms.languages).to include 'Spanish; Castilian', 'Dutch; Flemish'
    end

    it 'passes thru language values that are already text (not code)' do
      expect(mult_terms.languages).to include 'Spanish', 'Dutch'
    end

    it 'preserves values that are not inside <languageTerm> elements' do
      expect(mods_record('<language>Greek</language>').languages).to eq(['Greek'])
    end

    it 'creates a separate value for each language in a comma, space, or | separated list' do
      expect(mult_codes.languages).to include 'Arabic', 'Persian', 'Dutch; Flemish'
    end
  end

  describe '#language' do
    describe '#languageTerm' do
      it 'has attribute accessors' do
        expect(iso639_2b_code_ln.language.languageTerm).to have_attributes(
          type_at: ['code'],
          authority: ['iso639-2b'],
          text: 'fre',
          size: 1
        )
      end

      it 'recognizes other authority attributes' do
        language = mods_record("<language><languageTerm authorityURI='http://example.com' valueURI='http://example.com/zzz'>zzz</languageTerm></language>").language
        expect(language.languageTerm).to have_attributes(authorityURI: ['http://example.com'], valueURI: ['http://example.com/zzz'])
      end
    end

    describe '#code_term' do
      it "gets one language.code_term for each languageTerm element with a type attribute of 'code'" do
        expect(iso639_2b_code_ln.language.code_term.map(&:text)).to eq ['fre']
        expect(mult_terms.language.code_term.map(&:text)).to eq %w[spa dut]
      end
    end

    describe '#text_term' do
      it "gets one language.text_term for each languageTerm element with a type attribute of 'text'" do
        expect(mult_terms.language.text_term.map(&:text)).to eq %w[Spanish Dutch]
      end
    end
  end
end
