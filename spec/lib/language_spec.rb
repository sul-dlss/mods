require 'spec_helper'

RSpec.describe 'Mods <language> Element' do
  context 'with a simple record one with language term' do
    subject(:record) do
      mods_record("<language><languageTerm authority='iso639-2b' type='code'>fre</languageTerm></language>")
    end

    describe '#languages' do
      it 'translates the code into text' do
        expect(record.languages).to eq(['French'])
      end
    end

    describe '#language' do
      describe '#languageTerm' do
        it 'has attribute accessors' do
          expect(record.language.languageTerm).to have_attributes(
            type_at: ['code'],
            authority: ['iso639-2b'],
            text: 'fre',
            size: 1
          )
        end
      end

      describe '#code_term' do
        it 'gets the languageTerms with type="code"' do
          expect(record.language.code_term.map(&:text)).to eq ['fre']
        end
      end

      describe '#text_term' do
        it 'filters out the languageTerms with type="code"' do
          expect(record.language.text_term).to be_empty
        end
      end
    end
  end

  context 'with a record with a mix of language codes and plain-text languages' do
    subject(:record) do
      mods_record(<<-XML)
        <language>
          <languageTerm authority='iso639-2b' type='code'>spa</languageTerm>
          <languageTerm authority='iso639-2b' type='text'>Spanish</languageTerm>
          <languageTerm authority='iso639-2b' type='code'>dut</languageTerm>
          <languageTerm authority='iso639-2b' type='text'>Dutch</languageTerm>
        </language>
      XML
    end

    describe '#languages' do
      it 'translates the code into text' do
        expect(record.languages).to include 'Spanish; Castilian', 'Dutch; Flemish'
      end

      it 'passes thru language values that are already text (not code)' do
        expect(record.languages).to include 'Spanish', 'Dutch'
      end
    end

    describe '#language' do
      describe '#code_term' do
        it 'gets the languageTerms with type="code"' do
          expect(record.language.code_term.map(&:text)).to eq ['spa', 'dut']
        end
      end

      describe '#text_term' do
        it 'filters out the languageTerms with type="code"' do
          expect(record.language.text_term.map(&:text)).to eq %w[Spanish Dutch]
        end
      end
    end
  end

  context 'with a record with multiple language codes in one element' do
    subject(:record) do
      mods_record(<<-XML)
        <language>
          <languageTerm authority='iso639-2b' type='code'>per ara, dut</languageTerm>
        </language>
      XML
    end

    describe '#languages' do
      it 'creates a separate value for each language in a comma, space, or | separated list' do
        expect(record.languages).to include 'Arabic', 'Persian', 'Dutch; Flemish'
      end
    end
  end

  context 'with a record without a languageTerm child' do
    subject(:record) do
      mods_record(<<-XML)
        <language>Greek</language>
      XML
    end

    describe '#languages' do
      it 'preserves values that are not inside <languageTerm> elements' do
        expect(mods_record('<language>Greek</language>').languages).to eq(['Greek'])
      end
    end
  end

  context 'with a record with some authority attributes' do
    subject(:record) do
      mods_record(<<-XML)
        <language><languageTerm authorityURI='http://example.com' valueURI='http://example.com/zzz'>zzz</languageTerm></language>
      XML
    end

    describe '#language' do
      describe '#languageTerm' do
        it 'recognizes other authority attributes' do
          expect(record.language.languageTerm).to have_attributes(authorityURI: ['http://example.com'], valueURI: ['http://example.com/zzz'])
        end
      end
    end
  end

  context 'when language code without authority' do
    subject(:record) do
      mods_record(<<-XML)
        <language>
          <languageTerm type="code">eng</languageTerm>
          <languageTerm type="text">English</languageTerm>
        </language>
      XML
    end

    describe '#languages' do
      it 'contains code and text value' do
        expect(record.languages).to eq ['eng', 'English']
      end
    end
  end
end
