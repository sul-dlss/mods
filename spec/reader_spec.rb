require 'spec_helper'

describe "Mods::Reader" do
  before(:all) do
    # url is for a namespaced document
    @example_url = 'http://www.loc.gov/standards/mods/v3/mods99042030_linkedDataAdded.xml'
    @example_no_ns_str = '<mods><note>hi</note></mods>'
    @example_wrong_ns_str = '<mods xmlns="whoops"><note>hi</note></mods>'
    @from_no_ns_str = Mods::Reader.new.from_str(@example_no_ns_str)    
    @from_wrong_ns_str = Mods::Reader.new.from_str(@example_wrong_ns_str)    
    @from_url = Mods::Reader.new.from_url(@example_url)
    @ns_hash = {'mods' => Mods::MODS_NS}
  end
  
  it "from_str should turn an xml string into a Nokogiri::XML::Document object" do
    @from_no_ns_str.class.should == Nokogiri::XML::Document
    @from_wrong_ns_str.class.should == Nokogiri::XML::Document
  end
  
  it "from_url should turn the contents at the url into a Nokogiri::XML::Document object" do
    @from_url.class.should == Nokogiri::XML::Document
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
      @r = Mods::Reader.new
      @mods_ng_doc = @r.from_nk_node(@mods_node)
    end
    it "should turn the Nokogiri::XML::Node into a Nokogiri::XML::Document object" do
      @mods_ng_doc.should be_kind_of(Nokogiri::XML::Document)
    end
    it "should not care about namespace by default" do
      @mods_ng_doc.xpath('/mods/titleInfo/title').text.should == "boo"
    end
    it "should be able to care about namespaces" do
      @r.namespace_aware = true
      @mods_ng_doc = @r.from_nk_node(@mods_node)
      @mods_ng_doc.xpath('/mods:mods/mods:titleInfo/mods:title', @ns_hash).text.should == "boo"
      @r.namespace_aware = false
    end
    
  end

  context "namespace awareness" do
    it "should not care about namespace by default" do
      r = Mods::Reader.new
      r.namespace_aware.should == false
      @from_no_ns_str.xpath('/mods/note').text.should == "hi"
      @from_wrong_ns_str.xpath('/mods/note').text.should == "hi"
#      @from_no_ns_str.xpath('/mods:mods/mods:note', @ns_hash).text.should == ""
#      @from_wrong_ns_str.xpath('/mods:mods/mods:note', @ns_hash).text.should == ""
    end

    it "should be allowed to care about namespaces" do
      r = Mods::Reader.new
      r.namespace_aware = true
      r.from_url(@example_url).root.namespace.href.should == Mods::MODS_NS
      my_from_str_no_ns = r.from_str(@example_no_ns_str)
      my_from_str_no_ns.xpath('/mods:mods/mods:note', @ns_hash).text.should_not == "hi"
      my_from_str_wrong_ns = r.from_str(@example_wrong_ns_str)
      my_from_str_wrong_ns.root.namespace.href.should == 'whoops'
      my_from_str_wrong_ns.xpath('/mods:mods/mods:note', @ns_hash).text.should_not == "hi"
      my_from_str_wrong_ns.xpath('/mods/note').text.should_not == "hi"
    end
    
    it "should remove xsi:schemaLocation attribute from mods element if removing namespaces" do
      str = '<ns3:mods xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns3="http://www.loc.gov/mods/v3" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-2.xsd">
				<ns3:note>be very frightened</ns3:note></ns3:mods>'
			ng_xml = Nokogiri::XML(str)
			# Nokogiri treats namespaced attributes differently in jruby than in ruby
			(ng_xml.root.has_attribute?('schemaLocation') || ng_xml.root.has_attribute?('xsi:schemaLocation')).should == true
			r = Mods::Reader.new
      r.namespace_aware = true
      r.from_nk_node(ng_xml)
      r.mods_ng_xml.has_attribute?('schemaLocation').should == false
      r.mods_ng_xml.has_attribute?('xsi:schemaLocation').should == false
    end
  end
  
  it "should do something useful when it gets unparseable XML" do
    pending "need to implement error handling for bad xml"
  end
end