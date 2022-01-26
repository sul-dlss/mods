require 'spec_helper'

describe "Mods <relatedItem> Element" do
  context 'with a bibliography' do
    subject(:related_item) do
      mods_record(<<-XML).related_item.first
        <relatedItem displayLabel='Bibliography' type='host'>
            <titleInfo>
                <title/>
            </titleInfo>
            <recordInfo>
                <recordIdentifier source='Gallica ARK'/>
            </recordInfo>
            <typeOfResource>text</typeOfResource>
        </relatedItem>
      XML
    end

    it 'has the expected attributes' do
      expect(related_item).to have_attributes(
        displayLabel: 'Bibliography',
        type_at: 'host',
        recordInfo: match_array([
          have_attributes(recordIdentifier: match_array([have_attributes(source: 'Gallica ARK')]))
        ]),
        typeOfResource: match_array([have_attributes(text: 'text')])
      )
    end
  end

  context 'with a related item' do
    subject(:related_items) do
      mods_record(<<-XML).related_item
        <relatedItem>
          <titleInfo>
              <title>Complete atlas, or, Distinct view of the known world</title>
          </titleInfo>
          <name type='personal'>
              <namePart>Bowen, Emanuel,</namePart>
              <namePart type='date'>d. 1767</namePart>
          </name>
        </relatedItem>
        <relatedItem type='host' displayLabel='From:'>
          <titleInfo>
              <title>Complete atlas, or, Distinct view of the known world</title>
          </titleInfo>
          <name>
              <namePart>Bowen, Emanuel, d. 1767.</namePart>
          </name>
          <identifier type='local'>(AuCNL)1669726</identifier>
        </relatedItem>
      XML
    end

    it 'has the expected attributes' do
      expect(related_items).to match_array([
        have_attributes(
          displayLabel: [],
          titleInfo: match_array([have_attributes(title: have_attributes(text: 'Complete atlas, or, Distinct view of the known world'))]),
          personal_name: match_array([
            have_attributes(type_at: 'personal', display_value: 'Bowen, Emanuel,', date: match_array(have_attributes(text: 'd. 1767')))
          ])
        ),
        have_attributes(
          displayLabel: 'From:',
          type_at: 'host',
          identifier: match_array([
            have_attributes(type_at: 'local', text: '(AuCNL)1669726')
          ])
        )
      ])
    end
  end

  context 'with a constituent item' do
    subject(:related_item) do
      mods_record(<<-XML).related_item.first
        <relatedItem type='constituent' ID='MODSMD_ARTICLE1'>
          <titleInfo>
              <title>Nuppineula.</title>
          </titleInfo>
          <genre>article</genre>
          <part ID='DIVL15' type='paragraph' order='1'/>
          <part ID='DIVL17' type='paragraph' order='2'/>
          <part ID='DIVL19' type='paragraph' order='3'/>
        </relatedItem>
      XML
    end

    it 'has the expected attributes' do
      expect(related_item).to have_attributes(
        id_at: 'MODSMD_ARTICLE1',
        type_at: 'constituent',
        titleInfo: match_array([have_attributes(title: have_attributes(text: 'Nuppineula.'))]),
        genre: have_attributes(text: 'article'),
        part: match_array([
          have_attributes(id_at: 'DIVL15', type_at: 'paragraph', order: '1'),
          have_attributes(id_at: 'DIVL17', type_at: 'paragraph', order: '2'),
          have_attributes(id_at: 'DIVL19', type_at: 'paragraph', order: '3')
        ])
      )
    end
  end

  context 'with a collection' do
    subject(:related_item) do
      mods_record(<<-XML).related_item.first
        <relatedItem type='host'>
          <titleInfo>
            <title>The Collier Collection of the Revs Institute for Automotive Research</title>
          </titleInfo>
          <typeOfResource collection='yes'/>
        </relatedItem>
      XML
    end

    it 'has the expected attributes' do
      expect(related_item).to have_attributes(
        titleInfo: match_array([have_attributes(title: have_attributes(text: 'The Collier Collection of the Revs Institute for Automotive Research'))]),
        typeOfResource: match_array([have_attributes(collection: 'yes')])
      )
    end
  end
end
