require 'spec_helper'

describe "Mods::Record" do
  context "from_str" do
    before(:all) do
      @mods_ng_doc_w_ns = mods_record('<note>default ns</note>')
    end
    it "should return a mods record" do
      expect(@mods_ng_doc_w_ns).to be_a_kind_of(Mods::Record)
    end
    it "should have namespace aware parsing turned on by default" do
      expect(@mods_ng_doc_w_ns.namespaces.size).to be > 0
    end
    it "terminology should work with Record object defaults when mods string has namespaces" do
      expect(@mods_ng_doc_w_ns.note.map { |e| e.text }).to eq(['default ns'])
    end
    it "terminology should not work with Record object defaults when mods string has NO namespaces" do
      mods_ng_doc = Mods::Record.new.from_str('<mods><note>no ns</note></mods>')
      expect(mods_ng_doc.note.size).to eq(0)
    end
  end

  # Be able to create a new Mods::Record from a url
  context "from_url" do
    before(:all) do
      @mods_doc = Mods::Record.new.from_url('http://www.loc.gov/standards/mods/modsrdf/examples/0001.xml')
    end
    it "should return a mods record" do
      expect(@mods_doc).to be_a_kind_of(Mods::Record)
    end
    it "should raise an error on a bad url" do
      expect{Mods::Record.new.from_url("http://example.org/fake.xml")}.to raise_error
    end
  end

  # Be able to create a new Mods::Record from a file
  context "from_file" do
    before(:all) do
      @fixture_dir = File.join(File.dirname(__FILE__), '../fixture_data')
      @mods_doc = Mods::Record.new.from_file(File.join(@fixture_dir, 'shpc1.mods.xml'))
    end
    it "should return a mods record" do
      expect(@mods_doc).to be_a_kind_of(Mods::Record)
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
      @mods_node = ng_xml.xpath('//mods:mods', mods: 'http://www.loc.gov/mods/v3').first
      @mods_ng_doc = Mods::Record.new.from_nk_node(@mods_node)
      bad_ns_wrapped = '<?xml version="1.0" encoding="UTF-8"?>
      <metadata>
				<n:mods xmlns:n="http://www.not.mods.org">
					<n:titleInfo>
						<n:title>What? No namespaces?</n:title>
					</n:titleInfo>
				</n:mods>
      </metadata>'
      ng_xml = Nokogiri::XML(bad_ns_wrapped)
      @mods_node_no_ns = ng_xml.xpath('//n:mods', {'n'=>'http://www.not.mods.org'}).first
    end
    it "should return a mods record" do
      expect(@mods_ng_doc).to be_a_kind_of(Mods::Record)
    end
    it "should have namespace aware parsing turned on by default" do
      expect(@mods_ng_doc.namespaces.size).to be > 0
    end
    it "terminology should work with Record object defaults when mods string has namespaces" do
      expect(@mods_ng_doc.title_info.title.map { |e| e.text }).to eq(["boo"])
    end
    it "terminology should not work with Record object defaults when mods node has NO namespaces" do
      mods_ng_doc = Mods::Record.new.from_nk_node(@mods_node_no_ns)
      expect(mods_ng_doc.title_info.title.size).to eq(0)
    end
  end # context from_nk_node

  context "getting term values" do
    subject(:mods_rec) do
      mods_record(<<-XML)
        <abstract>single</abstract>
        <genre></genre>
        <note>mult1</note>
        <note>mult2</note>
        <subject><topic>topic1</topic><topic>topic2</topic></subject>
        <subject><topic>topic3</topic></subject>
      XML
    end

    context "term_value (single value result)" do
      it "should return nil if there are no such values in the MODS" do
        expect(mods_rec.term_value(:identifier)).to be_nil
      end
      it "should return nil if there are only empty values in the MODS" do
        expect(mods_rec.term_value(:genre)).to be_nil
      end
      it "should return a String for a single value" do
        expect(mods_rec.term_value(:abstract)).to eq('single')
      end
      it "should return a String containing all values, with separator, for multiple values" do
        expect(mods_rec.term_value(:note)).to eq('mult1 mult2')
      end
      it "should work with an Array of messages passed as the argument" do
        expect(mods_rec.term_value([:subject, 'topic'])).to eq('topic1 topic2 topic3')
      end
      it "should take a separator argument" do
        expect(mods_rec.term_value(:note, ' -|-')).to eq('mult1 -|-mult2')
      end
    end

    context "term_values (multiple values)" do
      it "should return nil if there are no such values in the MODS" do
        expect(mods_rec.term_values(:identifier)).to be_nil
      end
      it "should return nil if there are only empty values in the MODS" do
        expect(mods_rec.term_values(:genre)).to be_nil
      end
      it "should return an array of size one for a single value" do
        expect(mods_rec.term_values(:abstract)).to eq(['single'])
      end
      it "should return an array of values for multiple values" do
        expect(mods_rec.term_values(:note)).to eq(['mult1', 'mult2'])
      end
      it "should work with an Array of messages passed as the argument" do
        expect(mods_rec.term_values([:subject, 'topic'])).to eq(['topic1', 'topic2', 'topic3'])
      end
      it "should work with a String passed as the argument" do
        expect(mods_rec.term_values('abstract')).to eq(['single'])
      end
      it "should raise an error for an unrecognized message symbol" do
        expect { mods_rec.term_values(:not_there) }.to raise_error(ArgumentError, "term_values called with unknown argument: :not_there")
      end
      it "should raise an error if the argument is an Array containing non-symbols" do
        expect { mods_rec.term_values([:subject, mods_rec.subject]) }.to raise_error(ArgumentError, /term_values called with Array containing unrecognized class:.*NodeSet.*/)
      end
      it "should raise an error if the argument isn't a Symbol or an Array" do
        expect { mods_rec.term_values(mods_rec.subject) }.to raise_error(ArgumentError, /term_values called with unrecognized argument class:.*NodeSet.*/)
      end
    end
  end # getting term values

  context "convenience methods for accessing tricky bits of terminology" do
    context "title methods" do
      it "short_titles should return an Array of Strings (multiple titles are legal in Mods)" do
        record = mods_record("<titleInfo><title>Jerk</title><nonSort>The</nonSort></titleInfo><titleInfo><title>Joke</title></titleInfo>")
        expect(record.short_titles).to eq(["The Jerk", "Joke"])
      end
      it "full_titles should return an Array of Strings (multiple titles are legal in Mods)" do
        record = mods_record("<titleInfo><title>Jerk</title><nonSort>The</nonSort></titleInfo><titleInfo><title>Joke</title></titleInfo>")
        expect(record.full_titles).to eq(["The Jerk", "Joke"])
      end
      it "sort_title should return a String (sortable fields are single valued)" do
        record = mods_record("<titleInfo><title>Jerk</title><subTitle>A Tale of Tourettes</subTitle><nonSort>The</nonSort></titleInfo>")
        expect(record.sort_title).to eq("Jerk A Tale of Tourettes")
      end
      it "alternative_titles should return an Array of Strings (multiple alternative titles when there are multiple titleInfo elements)" do
        record = mods_record("<titleInfo type='alternative'><title>1</title></titleInfo><titleInfo type='alternative'><title>2</title></titleInfo>")
        expect(record.alternative_titles).to eq(['1', '2'])
        record = mods_record("<titleInfo type='alternative'><title>1</title><title>2</title></titleInfo>")
        expect(record.alternative_titles).to eq(['12'])
      end
    end

    context "personal_names" do
      before(:all) do
        @pers_name = 'Crusty'
        @pers_role = 'creator'
        @given_family = mods_record('<name type="personal"><namePart type="given">Jorge Luis</namePart><namePart type="family">Borges</namePart></name>')
        @given_family_date = mods_record('<name type="personal"><namePart type="given">Zaphod</namePart>
                                <namePart type="family">Beeblebrox</namePart>
                                <namePart type="date">1912-2362</namePart></name>')
        @all_name_parts = mods_record('<name type="personal"><namePart type="given">Given</namePart>
                                <namePart type="family">Family</namePart>
                                <namePart type="termsOfAddress">Mr.</namePart>
                                <namePart type="date">date</namePart></name>')
        @family_only = mods_record('<name type="personal"><namePart type="family">Family</namePart></name>')
        @given_only  = mods_record('<name type="personal"><namePart type="given">Given</namePart></name>')
      end

      it "should return an Array of Strings" do
        record = mods_record("<name type='personal'><namePart>#{@pers_name}</namePart></name>")
        expect(record.personal_names).to eq([@pers_name])
      end

      it "should not include the role text" do
        record = mods_record("<name type='personal'><namePart>#{@pers_name}</namePart></name>")
        expect(record.personal_names.first).not_to match(@pers_role)
      end

      it "should prefer displayForm over namePart pieces" do
        display_form_and_name_parts = mods_record('<name type="personal"><namePart type="given">Jorge Luis</namePart>
                                <namePart type="family">Borges</namePart>
                                <displayForm>display form</displayForm></name>')
        expect(display_form_and_name_parts.personal_names).to include("display form")
      end

      it "should put the family namePart first" do
        expect(@given_family.personal_names.first).to match(/^Borges/)
        expect(@given_family_date.personal_names.first).to match(/^Beeblebrox/)
      end
      it "should not include date" do
        expect(@given_family_date.personal_names.first).not_to match(/19/)
        expect(@all_name_parts.personal_names.first).not_to match('date')
      end
      it "should include a comma when there is both a family and a given name" do
        expect(@all_name_parts.personal_names).to include("Family, Given Mr.")
      end
      it "should include multiple words in a namePart" do
        expect(@given_family.personal_names).to include("Borges, Jorge Luis")
      end
      it "should not include a comma when there is only a family or given name" do
        expect(@family_only.personal_names.first).not_to match(/,/)
        expect(@given_only.personal_names.first).not_to match(/,/)
      end
      it "should include terms of address" do
        expect(@all_name_parts.personal_names.first).to match(/Mr./)
      end
    end # personal_names

    context "personal_names_w_dates" do
      before(:all) do
        @given_family = mods_record('<name type="personal"><namePart type="given">Jorge Luis</namePart>
                                <namePart type="family">Borges</namePart></name>')
        @given_family_date = mods_record('<name type="personal"><namePart type="given">Zaphod</namePart>
                                <namePart type="family">Beeblebrox</namePart>
                                <namePart type="date">1912-2362</namePart></name>')
        @all_name_parts = mods_record('<name type="personal"><namePart type="given">Given</namePart>
                                <namePart type="family">Family</namePart>
                                <namePart type="termsOfAddress">Mr.</namePart>
                                <namePart type="date">date</namePart></name>')
      end
      it "should return an Array of Strings" do
        expect(@given_family_date.personal_names_w_dates).to be_an_instance_of(Array)
      end
      it "should include the date when it is available" do
        expect(@given_family_date.personal_names_w_dates.first).to match(/, 1912-2362$/)
        expect(@all_name_parts.personal_names_w_dates.first).to match(/, date$/)
      end
      it "should be just the personal_name if no date is available" do
        expect(@given_family.personal_names_w_dates.first).to eq('Borges, Jorge Luis')
      end
    end

    context "corporate_names" do
      before(:all) do
        @corp_name = 'ABC corp'
      end
      it "should return an Array of Strings" do
        record = mods_record("<name type='corporate'><namePart>#{@corp_name}</namePart></name></mods>")
        expect(record.corporate_names).to eq([@corp_name])
      end
      it "should not include the role text" do
        corp_role = 'lithographer'
        mods_w_corp_name_role = mods_record("<name type='corporate'><namePart>#{@corp_name}</namePart>
          <role><roleTerm type='text'>#{corp_role}</roleTerm></role></name>")
        expect(mods_w_corp_name_role.corporate_names.first).not_to match(corp_role)
      end

      it "should prefer displayForm over namePart pieces" do
        display_form_and_name_parts = mods_record("<name type='corporate'><namePart>Food, Inc.</namePart>
                                <displayForm>display form</displayForm></name>")
        expect(display_form_and_name_parts.corporate_names).to include("display form")
      end
    end # corporate_names
  end # convenience methods for tricky bits of terminology

end
