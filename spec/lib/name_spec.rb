require 'spec_helper'

RSpec.describe "Mods <name> Element" do
  context 'with a record with a provided language' do
    subject(:record) do
      mods_record(<<-XML)
        <name type='personal'><namePart xml:lang='fr-FR' type='given'>Jean</namePart><namePart xml:lang='en-US' type='given'>John</namePart></name>
      XML
    end

    it "has the expected attributes" do
      expect(record.personal_name.namePart).to match_array([
        have_attributes(text: 'Jean', lang: 'fr-FR', type_at: 'given'),
        have_attributes(text: 'John', lang: 'en-US', type_at: 'given'),
      ])
    end
  end

  context 'with a recod without a role' do
    subject(:record) do
      mods_record(<<-XML)
        <name type='personal'><namePart>Crusty</namePart></name>
      XML
    end

    it 'does not have a role' do
      expect(record.personal_name.role).to be_empty
      expect(record.personal_name.role.code).to be_empty
      expect(record.personal_name.role.authority).to be_empty
    end
  end

  context 'with a record with a text role' do
    subject(:record) do
      mods_record(<<-XML)
        <name type='personal'><namePart>Crusty</namePart>
        <role><roleTerm authority='marcrelator' type='text'>creator</roleTerm><role></name>
      XML
    end

    it 'has the expected attributes' do
      expect(record.plain_name.first).to have_attributes(
        type_at: 'personal',
        namePart: match_array([
          have_attributes(text: 'Crusty')
        ]),
        role: have_attributes(
          roleTerm: have_attributes(
            text: 'creator',
            type_at: ['text'],
            authority: ['marcrelator']
          ),
          authority: ['marcrelator'],
          code: [],
          value: ['creator']
        )
      )
    end
  end

  context 'with a record with a code role' do
    subject(:record) do
      mods_record(<<-XML)
        <name type='personal'>
          <namePart type='given'>John</namePart>
          <namePart type='family'>Huston</namePart>
          <role>
              <roleTerm type='code' authority='marcrelator'>drt</roleTerm>
          </role>
        </name>
      XML
    end

    it 'has the expected attributes' do
      expect(record.plain_name.first).to have_attributes(
        type_at: 'personal',
        display_value: 'Huston, John',
        namePart: match_array([
          have_attributes(text: 'John', type_at: 'given'),
          have_attributes(text: 'Huston', type_at: 'family'),
        ]),
        role: have_attributes(
          roleTerm: have_attributes(
            text: 'drt',
            type_at: ['code'],
            authority: ['marcrelator'],
            value: ['Director']
          ),
          authority: ['marcrelator'],
          code: ['drt'],
          value: ['Director']
        )
      )
    end
  end

  context 'with an alternate name' do
    subject(:record) do
      mods_record(<<-XML)
        <name>
            <namePart>Claudia Alta Johnson</namePart>
            <alternativeName altType="nickname">
              <namePart>Lady Bird Johnson</namePart>
            </alternativeName>
        </name>
      XML
    end

    it 'has the expected attributes' do
      expect(record.plain_name.first).to have_attributes(
        namePart: have_attributes(text: 'Claudia Alta Johnson'),
        alternative_name: match_array([
          have_attributes(
            altType: 'nickname',
            namePart: have_attributes(text: 'Lady Bird Johnson')
          )
        ])
      )
    end
  end

  context 'with both a personal and corporate name' do
    subject(:record) do
      mods_record(<<-XML)
        <name type='corporate'><namePart>ABC Corp</namePart></name>
        <name type='personal'><namePart>Crusty</namePart></name>
      XML
    end

    describe '#personal_name' do
      it 'selects the name with the type "personal"' do
        expect(record.personal_name).to match_array([
          have_attributes(text: 'Crusty')
        ])
      end
    end

    describe '#corporate_name' do
      it 'selects the name with the type "corporate"' do
        expect(record.corporate_name).to match_array([
          have_attributes(text: 'ABC Corp')
        ])
      end
    end
  end

  context 'with a role with both text and a code' do
    subject(:record) do
      mods_record <<-XML
        <name><namePart>anyone</namePart>
          <role>
            <roleTerm type='text' authority='marcrelator'>CreatorFake</roleTerm>
            <roleTerm type='code' authority='marcrelator'>cre</roleTerm>
          </role>
        </name>
      XML
    end

    it 'prefers the value of the text term' do
      expect(record.plain_name.role.value).to eq ['CreatorFake']
    end

    it 'can return the code' do
      expect(record.plain_name.role.code).to eq ['cre']
    end
  end

  context 'with multiple roles' do
    subject(:record) do
      mods_record <<-XML
        <name><namePart>Fats Waller</namePart>
          <role>
            <roleTerm type='text' authority='marcrelator'>CreatorFake</roleTerm>
            <roleTerm type='code' authority='marcrelator'>cre</roleTerm>
          </role>
          <role>
            <roleTerm type='text'>Performer</roleTerm>
          </role>
        </name>
      XML
    end

    it 'returns both values' do
      expect(record.plain_name.role.value).to eq ['CreatorFake', 'Performer']
    end

    it 'can return the code' do
      expect(record.plain_name.role.code).to eq ['cre']
    end
  end

  context 'with additional name metadata' do
    subject(:record) do
      mods_record <<-XML
        <name>
          <namePart>Exciting Prints</namePart>
          <affiliation>whatever</affiliation>
          <description>anything</description>
          <role><roleTerm type='text'>some role</roleTerm></role>
        </name>
      XML
    end

    describe '#display_value' do
      it 'has the expected value' do
        expect(record.plain_name.first.display_value).to eq 'Exciting Prints'
      end
    end
  end

  context 'with an empty name' do
    subject(:record) do
      mods_record <<-XML
        <name>
          <namePart></namePart>
        </name>
      XML
    end

    describe '#display_value' do
      it 'is blank' do
        expect(record.plain_name.first.display_value).to be_nil
      end
    end
  end

  context 'with a displayForm' do
    subject(:record) do
      mods_record <<-XML
        <name type='personal'>
          <namePart>Alterman, Eric</namePart>
          <displayForm>Eric Alterman</displayForm>
        </name>
      XML
    end

    describe '#display_value' do
      it 'is the displayForm' do
        expect(record.plain_name.first.display_value).to eq 'Eric Alterman'
      end
    end
  end

  context 'with a record with a displayForm that includes some dates' do
    subject(:record) do
      mods_record <<-XML
        <name>
          <namePart>Woolf, Virginia</namePart>
          <namePart type='date'>1882-1941</namePart>
          <displayForm>Woolf, Virginia, 1882-1941</namePart>
        </name>
      XML
    end

    describe '#display_value_w_dates' do
      it 'does not duplicate the dates' do
        expect(record.plain_name.first.display_value).to eq 'Woolf, Virginia, 1882-1941'
        expect(record.plain_name.first.display_value_w_date).to eq 'Woolf, Virginia, 1882-1941'
      end
    end
  end

  context 'with a record with a namePart for dates' do
    subject(:record) do
      mods_record(<<-XML)
        <name>
          <namePart>Suzy</namePart>
          <namePart type='date'>1920-</namePart>
        </name>
      XML
    end

    it 'has the expected attributes' do
      expect(record.plain_name.first).to have_attributes(
        display_value: 'Suzy',
        display_value_w_date: 'Suzy, 1920-'
      )
    end
  end

  context 'without a family name and given name' do
    subject(:record) do
      mods_record("<name type='personal'>
                <namePart type='given'>John Paul</namePart>
                <namePart type='termsOfAddress'>II</namePart>
                <namePart type='termsOfAddress'>Pope</namePart>
                <namePart type='date'>1920-2005</namePart>
            </name>")
    end

    describe '#display_value' do
      it 'just concatenates the name parts' do
        expect(record.personal_name.first.display_value).to eq 'John Paul II, Pope'
      end
    end

    describe '#display_value_w_date' do
      it 'includes the dates' do
       expect(record.personal_name.first.display_value_w_date).to eq 'John Paul II, Pope, 1920-2005'
      end
    end
  end

  context 'with a bunch of untyped name parts' do
    subject(:record) do
      mods_record("<name type='personal'>
                  <namePart>Crusty</namePart>
                  <namePart>The Clown</namePart>
                  <namePart type='date'>1920-2005</namePart>
              </name>")
    end

    describe '#display_value' do
      it 'concatenates the untyped name parts' do
        expect(record.personal_name.first.display_value).to eq('Crusty The Clown')
      end
    end
  end

  context 'with a corporate name' do
    subject(:record) do
      mods_record("<name type='corporate'>
            <namePart>United States</namePart>
            <namePart>Court of Appeals (2nd Circuit)</namePart>
        </name>")
    end

    it 'concatenates the untyped name parts' do
      expect(record.corporate_name.first.display_value).to eq('United States Court of Appeals (2nd Circuit)')
    end
  end

  context 'with a complex example' do
    subject(:record) do
      mods_record <<-XML
        <name>
            <namePart>Sean Connery</namePart>
            <role><roleTerm type='code' authority='marcrelator'>drt</roleTerm></role>
        </name>
        <name>
            <namePart>Pierce Brosnan</namePart>
            <role>
              <roleTerm type='text'>CreatorFake</roleTerm>
              <roleTerm type='code' authority='marcrelator'>cre</roleTerm>
            </role>
            <role><roleTerm type='text' authority='marcrelator'>Actor</roleTerm></role>
        </name>
        <name>
            <namePart>Daniel Craig</namePart>
            <role>
              <roleTerm type='text' authority='marcrelator'>Actor</roleTerm>
              <roleTerm type='code' authority='marcrelator'>cre</roleTerm>
            </role>
        </name>
      XML
    end

    it 'has the expected attributes' do
      expect(record.plain_name).to match_array([
        have_attributes(role: have_attributes(value: ['Director'], code: ['drt'], authority: ['marcrelator'], size: 1)),
        have_attributes(role: have_attributes(value: ['CreatorFake', 'Actor'], code: ['cre'], authority: ['marcrelator', 'marcrelator'], size: 2)),
        have_attributes(role: have_attributes(value: ['Actor'], code: ['cre'], authority: ['marcrelator'], size: 1)),
      ])
    end
  end
end
