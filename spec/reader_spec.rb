require 'spec_helper'
require 'mods'

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
  end
  
  it "should do something useful when it gets unparseable XML" do
    pending "need to implement error handling for bad xml"
  end
end