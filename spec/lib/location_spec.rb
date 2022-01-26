# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Mods <location> Element' do
  context 'with a record with a physical location' do
    subject(:record) do
      mods_record('<location><physicalLocation>here</physicalLocation></location>')
    end

    it 'has access to text value of element' do
      expect(record.location.physicalLocation.text).to eq('here')
    end
  end

  context 'with a record with a physical location that has an authority' do
    subject(:record) do
      mods_record("<location><physicalLocation authority='marcorg'>MnRM</physicalLocation></location>")
    end

    it 'has access to text value of element' do
      expect(record.location.physicalLocation.map(&:text)).to eq(['MnRM'])
    end

    it 'recognizes authority attribute' do
      expect(record.location.physicalLocation.authority).to eq(['marcorg'])
    end
  end

  context 'with a record with a displayLabel' do
    subject(:record) do
      mods_record("<location><physicalLocation displayLabel='Correspondence'>some address</physicalLocation></location>")
    end

    it 'recognizes displayLabel attribute' do
      expect(record.location.physicalLocation.displayLabel).to eq(['Correspondence'])
    end
  end

  context 'with a record with a shelfLocator' do
    subject(:record) do
      mods_record(<<-XML)
        <location>
          <physicalLocation>Library of Congress </physicalLocation>
          <shelfLocator>DAG no. 1410</shelfLocator>
        </location>
      XML
    end

    it 'has a shelfLocator child element' do
      expect(record.location.shelfLocator.map(&:text)).to eq(['DAG no. 1410'])
    end
  end

  context 'with a record with a url location' do
    let(:url_attribs) do
      mods_record(<<-XML).location.url
        <location>
          <url
            displayLabel='Digital collection of 46 images available online'
            usage='primary display'
            note='something'
            dateLastAccessed='2021-12-21'>
            http://searchworks.stanford.edu/?f%5Bcollection%5D%5B%5D=The+Reid+W.+Dennis+Collection+of+California+Lithographs&amp;view=gallery
          </url>
        </location>
      XML
    end

    it 'has the right attributes' do
      expect(url_attribs).to have_attributes(
        displayLabel: ['Digital collection of 46 images available online'],
        usage: ['primary display'],
        note: ['something'],
        dateLastAccessed: ['2021-12-21']
      )
    end
  end

  context 'with a record with multiple urls' do
    let(:mult_flavor_loc_urls) do
      mods_record(<<-XML).location.url
        <location>
          <url access='preview'>http://preview.org</url>
          <url access='object in context'>http://context.org</url>
          <url access='raw object'>http://object.org</url>
        </location>
      XML
    end

    describe '#url' do
      it 'has access to text value of element' do
        expect(mult_flavor_loc_urls.map(&:text)).to eq ['http://preview.org', 'http://context.org', 'http://object.org']
      end

      describe '#access' do
        it 'provides access to the access attributes' do
          expect(mult_flavor_loc_urls.access).to eq ['preview', 'object in context', 'raw object']
        end
      end
    end
  end

  context 'with an empty url element' do
    let(:empty_url) do
      mods_record(<<-XML).location.url
        <location><url /></location>
      XML
    end

    it 'is an empty string for single empty url element' do
      expect(empty_url.text).to be_empty
    end
  end

  context 'with a record with holdingSimple data' do
    subject(:record) do
      mods_record(<<-XML)
        <location>
          <physicalLocation authority='marcorg'>MnRM</physicalLocation>
          <holdingSimple>
            <copyInformation>
              <subLocation>Patient reading room</subLocation>
              <shelfLocator>QH511.A1J68</shelfLocator>
              <enumerationAndChronology unitType='1'> v.1-v.8 1970-1976</enumerationAndChronology>
            </copyInformation>
          </holdingSimple>
        </location>
      XML
    end

    it 'has aholdingSimple child element' do
      expect(record.location.holdingSimple.copyInformation.first).to have_attributes(
        sub_location: have_attributes(text: 'Patient reading room'),
        shelf_locator: have_attributes(text: 'QH511.A1J68'),
        enumeration_and_chronology: have_attributes(text: ' v.1-v.8 1970-1976', unitType: ['1'])
      )
    end
  end

  context 'with a record with holdingComplex data' do
    subject(:record) do
      mods_record(<<-XML)
        <location>
          <physicalLocation>Menlo Park Public Library</physicalLocation>
          <holdingExternal>
            <holding xmlns='info:ofi/fmt:xml:xsd:iso20775' xsi:schemaLocation='info:ofi/fmt:xml:xsd:iso20775 http://www.loc.gov/standards/iso20775/N130_ISOholdings_v6_1.xsd'>
              <institutionIdentifier>
                <value>JRF</value>
                <typeOrSource>
                    <pointer>http://worldcat.org/registry/institutions/</pointer>
                </typeOrSource>
              </institutionIdentifier>
              <physicalLocation>Menlo Park Public Library</physicalLocation>
              <physicalAddress>
                <text>Menlo Park, CA 94025 United States </text>
              </physicalAddress>
              <electronicAddress>
                <text>http://www.worldcat.org/wcpa/oclc/15550774? page=frame&amp;url=%3D%3FUTF-8%3FB%FaHR0cDovL2NhdGFsb2cucGxzaW5mby5vcmcvc2VhcmNoL2kwMTk1MDM4NjMw%3F%3D&amp;title=Menlo+Park+Public+Library&amp;linktype=opac&amp;detail=JRF%3AMenlo+Park+Public+Library%3APublic&amp;app=wcapi&amp;id=OCL-OCLC+Staff+use</text>
              </electronicAddress>
              <holdingSimple>
                <copiesSummary>
                  <copiesCount>1</copiesCount>
                </copiesSummary>
              </holdingSimple>
            </holding>
          </holdingExternal>
        </location>
      XML
    end

    it 'has a holdingComplex child element' do
      expect(record.location.holdingExternal.xpath('//h:holding/h:physicalLocation',
                                                   h: 'info:ofi/fmt:xml:xsd:iso20775').map(&:text)).to eq ['Menlo Park Public Library']
    end
  end
end
