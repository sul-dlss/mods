# frozen_string_literal: true

require 'spec_helper'

describe 'Mods::Reader' do
  before(:all) do
    @ns_hash = { 'm' => Mods::MODS_NS }
    # url is for a namespaced document
    @example_url = 'http://www.loc.gov/standards/mods/v3/mods99042030_linkedDataAdded.xml'
    @example_default_ns_str = '<mods xmlns="http://www.loc.gov/mods/v3"><note>default ns</note></mods>'
    @example_ns_str         = '<mods:mods xmlns:mods="http://www.loc.gov/mods/v3"><mods:note>ns</mods:note></mods:mods>'
    @example_no_ns_str      = '<mods><note>no ns</note></mods>'
    @example_wrong_ns_str   = '<mods xmlns="wrong"><note>wrong ns</note></mods>'
    @doc_from_str_default_ns = Mods::Reader.new.from_str(@example_ns_str)
    @doc_from_str_ns         = Mods::Reader.new.from_str(@example_ns_str)
    @doc_from_str_no_ns      = Mods::Reader.new.from_str(@example_no_ns_str)
    @doc_from_str_wrong_ns   = Mods::Reader.new.from_str(@example_wrong_ns_str)
    @from_url = Mods::Reader.new.from_url(@example_url)
  end

  it 'from_str should turn an xml string into a Nokogiri::XML::Document object' do
    expect(@doc_from_str_default_ns).to be_instance_of(Nokogiri::XML::Document)
    expect(@doc_from_str_ns).to be_instance_of(Nokogiri::XML::Document)
    expect(@doc_from_str_no_ns).to be_instance_of(Nokogiri::XML::Document)
    expect(@doc_from_str_wrong_ns).to be_instance_of(Nokogiri::XML::Document)
  end

  context 'with from_url' do
    it 'turns the contents at the url into a Nokogiri::XML::Document object' do
      expect(@from_url).to be_instance_of(Nokogiri::XML::Document)
    end
  end

  context 'with from_file' do
    before(:all) do
      @fixture_dir = File.join(File.dirname(__FILE__), '../fixture_data')
      @fixture_mods_file = File.join(@fixture_dir, 'shpc1.mods.xml')
      @from_file = Mods::Reader.new.from_file(@fixture_mods_file)
    end

    it 'turns the contents of a file into a Nokogiri::XML::Document object' do
      expect(@from_file).to be_instance_of(Nokogiri::XML::Document)
    end

    it 'gives a meaningful error if passed a bad file' do
      expect(-> { Mods::Record.new.from_file('/fake/file') }).to raise_error
    end
  end

  context 'with namespace awareness' do
    it 'cares about namespace by default' do
      r = Mods::Reader.new
      expect(@doc_from_str_default_ns.root.namespace.href).to eq(Mods::MODS_NS)
      expect(@doc_from_str_default_ns.xpath('/m:mods/m:note', @ns_hash).text).to eq('ns')
      expect(@doc_from_str_default_ns.xpath('/mods/note').size).to eq(0)
      expect(@doc_from_str_ns.root.namespace.href).to eq(Mods::MODS_NS)
      expect(@doc_from_str_ns.xpath('/m:mods/m:note', @ns_hash).text).to eq('ns')
      expect(@doc_from_str_ns.xpath('/mods/note').size).to eq(0)
      expect(@doc_from_str_no_ns.xpath('/m:mods/m:note', @ns_hash).size).to eq(0)
      expect(@doc_from_str_no_ns.xpath('/mods/note').text).to eq('no ns')
      expect(@doc_from_str_wrong_ns.root.namespace.href).to eq('wrong')
      expect(@doc_from_str_wrong_ns.xpath('/m:mods/m:note', @ns_hash).size).to eq(0)
      expect(@doc_from_str_wrong_ns.xpath('/mods/note').size).to eq(0)
    end
  end

  context 'when normalizing mods' do
    it 'does not lose UTF-8 encoding' do
      utf_mods = '<?xml version="1.0" encoding="UTF-8"?>
                  <mods:mods xmlns:mods="http://www.loc.gov/mods/v3"
                  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.3"
                  xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd">
                    <mods:name authority="local" type="personal">
                      <mods:namePart>Gravé par Denise Macquart.</mods:namePart>
                    </mods:name>
                  </mods:mods>'
      reader = Mods::Reader.new.from_str(utf_mods)
      expect(reader.encoding).to eql('UTF-8')
    end
  end

  context 'when from_nk_node' do
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
      @mods_node = ng_xml.xpath('//m:mods', @ns_hash).first
      @r = Mods::Reader.new
      @mods_ng_doc = @r.from_nk_node(@mods_node)
    end

    it 'turns the Nokogiri::XML::Node into a Nokogiri::XML::Document object' do
      expect(@mods_ng_doc).to be_kind_of(Nokogiri::XML::Document)
    end

    it 'cares about namespace by default' do
      expect(@mods_ng_doc.xpath('/m:mods/m:titleInfo/m:title', @ns_hash).text).to eq('boo')
    end
  end
end
