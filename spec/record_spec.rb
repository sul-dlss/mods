require 'spec_helper'

describe "Mods::Record" do
  before(:all) do
    @ns_hash = {'mods' => Mods::MODS_NS}
  end

  context "from_str" do
    it "should be able to find element using NOM terminology" do
      mods_ng_doc = Mods::Record.new.from_str('<mods><note>hi</note></mods>')
      mods_ng_doc.note.map { |e| e.text } == "hi"
    end
  end
  
  context "from_nk_node" do
    before(:all) do
      oai_resp = '<?xml version="1.0" encoding="UTF-8"?>
      <OAI-PMH xmlns="http://www.openarchives.org/OAI/2.0/">
      	<responseDate>2012-11-13T22:11:35Z</responseDate>
      	<request>http://sul-lyberservices-prod.stanford.edu/sw-oai-provider/oai</request>
      	<GetRecord>
      		<record>
      			<header>
      				<identifier>oai:searchworks.stanford.edu/druid:mm848sz7984</identifier>
      				<datestamp>2012-10-28T01:06:31Z</datestamp>
      			</header>
      			<metadata>
      				<ns3:mods xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns3="http://www.loc.gov/mods/v3" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-2.xsd">
      					<ns3:titleInfo>
      						<ns3:title>boo</ns3:title>
      					</ns3:titleInfo>
      				</ns3:mods>
            </metadata>
          </record>
        </GetRecord>
      </OAI-PMH>'
      ng_xml = Nokogiri::XML(oai_resp)
      @mods_node = ng_xml.xpath('//mods:mods', @ns_hash).first
    end
    it "should be able to find element using NOM terminology" do
      mods_ng_doc = Mods::Record.new.from_nk_node(@mods_node)
      mods_ng_doc.title_info.title.map { |e| e.text } == "boo"
    end
  end

end