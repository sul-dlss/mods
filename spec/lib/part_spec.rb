require 'spec_helper'

RSpec.describe "Mods <part> Element" do
  context 'with a basicpart' do
    subject(:part) do
      mods_record("<part>
              <detail>
                  <title>Wayfarers (Poem)</title>
              </detail>
              <extent unit='pages'>
                  <start>97</start>
                  <end>98</end>
              </extent>
          </part>").part
    end

    it 'has the expected attributes' do
      expect(part.first).to have_attributes(
        detail: match_array([
          have_attributes(
            title: match_array([have_attributes(text: 'Wayfarers (Poem)')]),
            number: [],
          )
        ]),
        extent: match_array([
          have_attributes(
            unit: 'pages',
            start: have_attributes(text: '97'),
            end: have_attributes(text: '98'),
          )
        ])
      )
    end
  end
  context 'with a part with a detail number' do
    subject(:part) do
      mods_record("<part>
              <detail type='page number'>
                  <number>3</number>
              </detail>
              <extent unit='pages'>
                  <start>3</start>
              </extent>
          </part>").part
    end

    it 'has the expected attributes' do
      expect(part.first).to have_attributes(
        detail: match_array([
          have_attributes(
            type_at: 'page number',
            number: match_array([have_attributes(text: '3')])
          )
        ]),
        extent: match_array([
          have_attributes(
            unit: 'pages',
            start: have_attributes(text: '3')
          )
        ])
      )
    end
  end
  context 'with a part with a number and caption' do
    subject(:part) do
      mods_record("<part>
              <detail type='issue'>
                  <number>1</number>
                  <caption>no.</caption>
              </detail>
          </part>").part
    end

    it 'has the expected attributes' do
      expect(part.first).to have_attributes(
        detail: match_array([
          have_attributes(
            type_at: 'issue',
            number: match_array([have_attributes(text: '1')]),
            caption: match_array([have_attributes(text: 'no.')])
          )
        ])
      )
    end
  end

  context 'with a typed part' do
    subject(:part) do
      mods_record("<part ID='p1' order='1' type='paragraph'>anything</part>").part
    end

    it 'has the expected attributes' do
      expect(part.first).to have_attributes(
        id_at: 'p1',
        order: '1',
        type_at: 'paragraph',
        text: 'anything'
      )
    end
  end

  context 'with a level attribute' do
    subject(:part) { mods_record("<part><detail level='val'>anything</detail></part>").part }

    it 'has the expected attributes' do
      expect(part.first).to have_attributes(
        detail: match_array([have_attributes(level: 'val')])
      )
    end
  end

  context 'with a total element' do
    subject(:part) { mods_record("<part><extent><total>anything</total></extent></part>").part }

    it 'has the expected attributes' do
      expect(part.first).to have_attributes(
        extent: match_array([have_attributes(total: match_array([have_attributes(text: 'anything')]))])
      )
    end
  end

  context 'with a list element' do
    subject(:part) { mods_record("<part><extent><list>anything</list></extent></part>").part }

    it 'has the expected attributes' do
      expect(part.first).to have_attributes(
        extent: match_array([have_attributes(list: match_array([have_attributes(text: 'anything')]))])
      )
    end
  end

  context "<date> child element" do
    subject(:date) do
      mods_record("<part><date encoding='w3cdtf'>1999</date></part>").part.date
    end

    it 'has the expected date attributes' do
      expect(date.first).to have_attributes(
        encoding: 'w3cdtf',
        text: '1999',
        point: [],
        qualifier: []
      )
    end

    it 'does not have a keyDate attribute' do
      expect(date.first).not_to respond_to(:keyDate)
    end
  end

  context "<text> child element as .text_el term" do
    subject(:part) do
      mods_record("<part><text type='bar' displayLabel='foo'>1999</text></part>").part
    end

    describe '#text_el' do
      it "has the expected attributes" do
        expect(part.first.text_el).to have_attributes(text: '1999', displayLabel: ['foo'], type_at: ['bar'])
      end
    end
  end
end
