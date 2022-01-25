require 'spec_helper'

describe "Mods <location> Element" do
  context "basic location terminology pieces" do
    context "physicalLocation child element" do
      let(:phys_loc_only) do
        mods_record("<location><physicalLocation>here</physicalLocation></location>")
      end

      let(:phys_loc_authority) do
        mods_record("<location><physicalLocation authority='marcorg'>MnRM</physicalLocation></location>")
      end

      it "should have access to text value of element" do
        expect(phys_loc_only.location.physicalLocation.text).to eq("here")
        expect(phys_loc_authority.location.physicalLocation.map { |n| n.text }).to eq(["MnRM"])
      end

      it "should recognize authority attribute" do
        expect(phys_loc_authority.location.physicalLocation.authority).to eq(["marcorg"])
      end

      it "should recognize displayLabel attribute" do
        record = mods_record("<location><physicalLocation displayLabel='Correspondence'>some address</physicalLocation></location>")
        expect(record.location.physicalLocation.displayLabel).to eq(["Correspondence"])
      end
    end

    it "shelfLocator child element" do
      record = mods_record(<<-XML)
        <location>
          <physicalLocation>Library of Congress </physicalLocation>
          <shelfLocator>DAG no. 1410</shelfLocator>
        </location>
      XML

      expect(record.location.shelfLocator.map { |n| n.text }).to eq(["DAG no. 1410"])
    end

    context "url child element" do
      let(:mult_flavor_loc_urls) do
        mods_record(<<-XML)
          <location>
            <url access='preview'>http://preview.org</url>
            <url access='object in context'>http://context.org</url>
            <url access='raw object'>http://object.org</url>
          </location>
        XML
      end

      it "should have access to text value of element" do
        urls = mult_flavor_loc_urls.location.url.map { |e| e.text }
        expect(urls).to eq ["http://preview.org", "http://context.org", "http://object.org"]
      end

      context "attributes" do
        let(:url_attribs) do
          mods_record(<<-XML)
            <location>
              <url displayLabel='Digital collection of 46 images available online' usage='primary display'>http://searchworks.stanford.edu/?f%5Bcollection%5D%5B%5D=The+Reid+W.+Dennis+Collection+of+California+Lithographs&amp;view=gallery</url>
            </location>
          XML
        end
        it "should recognize displayLabel attribute" do
          expect(url_attribs.location.url.displayLabel).to eq(["Digital collection of 46 images available online"])
        end

        it "should recognize access attribute" do
          vals = mult_flavor_loc_urls.location.url.access
          expect(vals).to eq ['preview', 'object in context', 'raw object']
        end

        it "should recognize usage attribute" do
          expect(url_attribs.location.url.usage).to eq(["primary display"])
        end

        it "should recognize note attribute" do
          record = mods_record("<location><url note='something'>http://somewhere.org</url></location>")
          expect(record.location.url.note).to eq(["something"])
        end

        it "should recognize dateLastAccessed attribute" do
          record = mods_record("<location><url dateLastAccessed='something'>http://somewhere.org</url></location>")
          expect(record.location.url.dateLastAccessed).to eq(["something"])
        end
      end

      it "should have array with empty string for single empty url element" do
        expect(mods_record('<location><url /></location>').location.url.map { |n| n.text }).to eq([""])
      end
    end

    it "holdingSimple child element" do
      record = mods_record(<<-XML)
        <location>
        	<physicalLocation authority='marcorg'>MnRM</physicalLocation>
        	<holdingSimple>
            <copyInformation>
              <sublocation>Patient reading room</sublocation>
              <shelfLocator>QH511.A1J68</shelfLocator>
              <enumerationAndChronology unitType='1'> v.1-v.8 1970-1976</enumerationAndChronology>
            </copyInformation>
        	</holdingSimple>
        </location>
      XML

      expect(record.location.holdingSimple).to be_an_instance_of(Nokogiri::XML::NodeSet)
      expect(record.location.holdingSimple.first).to be_an_instance_of(Nokogiri::XML::Element)
    end

    it "holdingComplex child element" do
      record = mods_record(<<-XML)
        <location>
          <physicalLocation>Menlo Park Public Library</physicalLocation>
          <holdingExternal>
            <holding xmlns:iso20775='info:ofi/fmt:xml:xsd:iso20775' xsi:schemaLocation='info:ofi/fmt:xml:xsd:iso20775 http://www.loc.gov/standards/iso20775/N130_ISOholdings_v6_1.xsd'>
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

      expect(record.location.holdingExternal).to be_an_instance_of(Nokogiri::XML::NodeSet)
      expect(record.location.holdingExternal.first).to be_an_instance_of(Nokogiri::XML::Element)
    end
  end
end
