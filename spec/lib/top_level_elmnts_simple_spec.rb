# frozen_string_literal: true

require 'spec_helper'

describe 'Mods Top Level Elements that do not have Child Elements' do
  it 'gets the text contents of any single simple (cannot have child elements) top level element' do
    Mods::TOP_LEVEL_ELEMENTS_SIMPLE.each do |elname|
      record = mods_record("<#{elname}>hi</#{elname}>")
      expect(record.send(elname.to_sym).map(&:text)).to eq(['hi'])
    end
  end

  it 'returns an array of strings when there are multiple occurrences of simple top level elements' do
    expect(mods_record('<note>hi</note><note>hello</note></mods>').note.map(&:text)).to eq(%w[hi hello])
  end

  context 'with <abstract> child element' do
    it ".abstract.displayLabel should be an accessor for displayLabel attribute on abstract element: <abstract displayLabel='foo'>" do
      record = mods_record('<abstract displayLabel="Summary">blah blah blah</abstract>')
      expect(record.abstract.displayLabel).to eq(['Summary'])
    end

    it ".abstract.type_at should be an accessor for type attribute on abstract element: <abstract type='foo'>" do
      record = mods_record('<abstract type="Scope and Contents note">blah blah blah</abstract>')
      expect(record.abstract.type_at).to eq(['Scope and Contents note'])
    end
  end

  context 'with <accessCondition> child element' do
    before(:all) do
      @acc_cond = mods_record('<accessCondition displayLabel="meh" type="useAndReproduction">blah blah blah</accessCondition></mods>').accessCondition
      @acc_cond2 = mods_record('<accessCondition type="useAndReproduction">All rights reserved.</accessCondition></mods>').accessCondition
    end

    it ".accessCondition.displayLabel should be an accessor for displayLabel attribute on accessCondition element: <accessCondition displayLabel='foo'>" do
      expect(@acc_cond.displayLabel).to eq(['meh'])
    end

    it ".accessCondition.type_at should be an accessor for type attribute on accessCondition element: <accessCondition type='foo'>" do
      [@acc_cond, @acc_cond2].each { |ac| expect(ac.type_at).to eq(['useAndReproduction']) }
    end
  end

  context 'with <classification> child element' do
    before(:all) do
      @class1 = mods_record('<classification authority="ddc" edition="11">683</classification></mods>').classification
      @class2 = mods_record('<classification authority="lcc">JK609.M2</classification></mods>').classification
    end

    it ".classification.authority should be an accessor for authority attribute on classification element: <classification authority='foo'>" do
      expect(@class1.authority).to eq(['ddc'])
      expect(@class2.authority).to eq(['lcc'])
    end

    it ".classification.edition should be an accessor for edition attribute on classification element: <classification edition='foo'>" do
      expect(@class1.edition).to eq(['11'])
    end

    it 'recognizes all authority attributes' do
      Mods::AUTHORITY_ATTRIBS.each do |a|
        record = mods_record("<classification #{a}='attr_val'>zzz</classification>")
        expect(record.classification.send(a.to_sym)).to eq(['attr_val'])
      end
    end
  end

  context 'with <extension> child element' do
    before(:all) do
      @ext = record = mods_record('<extension xmlns:dcterms="http://purl.org/dc/ >
        <dcterms:modified>2003-03-24</dcterms:modified>
      </extension></mods>').extension
    end

    it ".extension.displayLabel should be an accessor for displayLabel attribute on extension element: <extension displayLabel='foo'>" do
      record = mods_record('<extension displayLabel="something">blah blah blah</extension>')
      expect(record.extension.displayLabel).to eq(['something'])
    end
  end

  context 'with <genre> child element' do
    it ".genre.displayLabel should be an accessor for displayLabel attribute on genre element: <genre displayLabel='foo'>" do
      record = mods_record('<genre displayLabel="something">blah blah blah</genre>')
      expect(record.genre.displayLabel).to eq(['something'])
    end

    it ".genre.type_at should be an accessor for type attribute on genre element: <genre type='foo'>" do
      record = mods_record('<genre type="maybe">blah blah blah</genre>')
      expect(record.genre.type_at).to eq(['maybe'])
    end

    it ".genre.usage should be an accessor for usage attribute on genre element: <genre usage='foo'>" do
      record = mods_record('<genre usage="fer sure">blah blah blah</genre>')
      expect(record.genre.usage).to eq(['fer sure'])
    end

    it 'recognizes all authority attributes' do
      Mods::AUTHORITY_ATTRIBS.each do |a|
        record = mods_record("<genre #{a}='attr_val'>zzz</genre>")
        expect(record.genre.send(a.to_sym)).to eq(['attr_val'])
      end
    end
  end

  context 'with <identifier> child element' do
    let(:record) do
      mods_record('<identifier displayLabel="book_number" type="local">70</identifier></mods>')
    end

    it ".identifier.displayLabel should be an accessor for displayLabel attribute on identifier element: <identifier displayLabel='foo'>" do
      expect(record.identifier.displayLabel).to eq(['book_number'])
    end

    it ".identifier.invalid should be an accessor for invalid attribute on identifier element: <identifier invalid='foo'>" do
      record = mods_record('<identifier type="isbn" invalid="yes">0877780116</identifier>')
      expect(record.identifier.invalid).to eq(['yes'])
    end

    it ".identifier.type_at should be an accessor for type attribute on identifier element: <identifier type='foo'>" do
      expect(record.identifier.type_at).to eq(['local'])
    end
  end

  context 'with <note> child element' do
    it ".note.displayLabel should be an accessor for displayLabel attribute on note element: <note displayLabel='foo'>" do
      record = mods_record('<note displayLabel="state_note">blah</note>')
      expect(record.note.displayLabel).to eq(['state_note'])
    end

    it ".note.id_at should be an accessor for ID attribute on note element: <note ID='foo'>" do
      record = mods_record('<note ID="foo">blah blah blah</note>')
      expect(record.note.id_at).to eq(['foo'])
    end

    it ".note.type_at should be an accessor for type attribute on note element: <note type='foo'>" do
      record = mods_record('<note type="content">blah</note>')
      expect(record.note.type_at).to eq(['content'])
    end
  end

  context 'with <tableOfContents> child element' do
    it ".tableOfContents.displayLabel should be an accessor for displayLabel attribute on tableOfContents element: <tableOfContents displayLabel='foo'>" do
      record = mods_record('<tableOfContents displayLabel="Chapters included in book">blah blah</tableOfContents>')
      expect(record.tableOfContents.displayLabel).to eq(['Chapters included in book'])
    end

    it ".tableOfContents.shareable should be an accessor for shareable attribute on tableOfContents element: <tableOfContents shareable='foo'>" do
      record = mods_record('<tableOfContents shareable="no">blah blah blah</tableOfContents>')
      expect(record.tableOfContents.shareable).to eq(['no'])
    end

    it ".tableOfContents.type_at should be an accessor for type attribute on tableOfContents element: <tableOfContents type='foo'>" do
      record = mods_record('<tableOfContents type="partial contents">blah blah</tableOfContents>')
      expect(record.tableOfContents.type_at).to eq(['partial contents'])
    end
  end

  context 'with <targetAudience> child element' do
    it ".targetAudience.displayLabel should be an accessor for displayLabel attribute on targetAudience element: <targetAudience displayLabel='foo'>" do
      record = mods_record('<targetAudience displayLabel="ta da">blah blah</targetAudience>')
      expect(record.targetAudience.displayLabel).to eq(['ta da'])
    end

    it 'recognizes all authority attributes' do
      Mods::AUTHORITY_ATTRIBS.each do |a|
        record = mods_record("<targetAudience #{a}='attr_val'>zzz</targetAudience>")
        expect(record.targetAudience.send(a.to_sym)).to eq(['attr_val'])
      end
    end
  end

  context 'with <typeOfResource> child element' do
    it ".typeOfResource.collection should be an accessor for collection attribute on typeOfResource element: <typeOfResource collection='foo'>" do
      record = mods_record('<typeOfResource collection="yes">blah blah blah</typeOfResource>')
      expect(record.typeOfResource.collection).to eq(['yes'])
    end

    it ".typeOfResource.displayLabel should be an accessor for displayLabel attribute on typeOfResource element: <typeOfResource displayLabel='foo'>" do
      record = mods_record('<typeOfResource displayLabel="Summary">blah blah blah</typeOfResource>')
      expect(record.typeOfResource.displayLabel).to eq(['Summary'])
    end

    it ".typeOfResource.manuscript should be an accessor for manuscript attribute on typeOfResource element: <typeOfResource manuscript='foo'>" do
      record = mods_record('<typeOfResource manuscript="yes">blah blah blah</typeOfResource>')
      expect(record.typeOfResource.manuscript).to eq(['yes'])
    end

    it ".typeOfResource.usage should be an accessor for usage attribute on typeOfResource element: <typeOfResource usage='foo'>" do
      record = mods_record('<typeOfResource usage="fer sure">blah blah blah</typeOfResource>')
      expect(record.typeOfResource.usage).to eq(['fer sure'])
    end
  end
end
