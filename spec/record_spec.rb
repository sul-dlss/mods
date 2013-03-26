require 'spec_helper'

describe "Mods::Record" do
  before(:all) do
    @ns_hash = {'mods' => Mods::MODS_NS}
    @def_ns_decl = "xmlns='#{Mods::MODS_NS}'"
    @example_ns_str = "<mods #{@def_ns_decl}><note>default ns</note></mods>"
    @example_no_ns_str = '<mods><note>no ns</note></mods>'
    @example_record_url = 'http://www.loc.gov/standards/mods/modsrdf/examples/0001.xml'
    @doc_from_str_ns = Mods::Reader.new.from_str(@example_ns_str) 
    @doc_from_str_no_ns = Mods::Reader.new.from_str(@example_no_ns_str) 
  end

  context "from_str" do
    before(:all) do
      @mods_ng_doc_w_ns = Mods::Record.new.from_str(@example_ns_str)
    end
    it "should have namespace aware parsing turned on by default" do
      @mods_ng_doc_w_ns.namespaces.size.should > 0
    end
    it "terminology should work with Record object defaults when mods string has namespaces" do
      @mods_ng_doc_w_ns.note.map { |e| e.text }.should == ['default ns']
    end
    it "terminology should not work with Record object defaults when mods string has NO namespaces" do
      mods_ng_doc = Mods::Record.new.from_str(@example_no_ns_str)
      mods_ng_doc.note.size.should == 0
    end
    it "should be allowed not to care about namespaces" do
      mods_ng_doc = Mods::Record.new.from_str(@example_no_ns_str, false)
      mods_ng_doc.note.map { |e| e.text }.should == ['no ns']
    end
  end

  context "from_url" do
    before(:all) do
      @mods_doc = Mods::Record.new.from_url(@example_record_url)
    end
    it "should be a mods record" do
      @mods_doc.kind_of? Mods::Record
    end
    it "should raise an error on a bad url" do
      Mods::Record.new.from_url("http://example.org/fake.xml").should raise_error
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
    it "should have namespace aware parsing turned on by default" do
      @mods_ng_doc.namespaces.size.should > 0
    end
    it "terminology should work with Record object defaults when mods string has namespaces" do
      @mods_ng_doc.title_info.title.map { |e| e.text }.should == ["boo"]
    end
    it "terminology should not work with Record object defaults when mods node has NO namespaces" do
      mods_ng_doc = Mods::Record.new.from_nk_node(@mods_node_no_ns)
      mods_ng_doc.title_info.title.size.should == 0
    end
    it "should be allowed not to care about namespaces" do
      mods_ng_doc = Mods::Record.new.from_nk_node(@mods_node_no_ns, false)
      mods_ng_doc.title_info.title.map { |e| e.text }.should == ["What? No namespaces?"]
    end
  end # context from_nk_node
  
  context "getting term values" do
    before(:all) do
      m = "<mods #{@def_ns_decl}>
        <abstract>single</abstract>
        <genre></genre>
        <note>mult1</note>
        <note>mult2</note>
        <subject><topic>topic1</topic><topic>topic2</topic></subject>
        <subject><topic>topic3</topic></subject>
      </mods>"
      @mods_rec = Mods::Record.new
      @mods_rec.from_str(m)
    end
    
    context "term_value (single value result)" do
      it "should return nil if there are no such values in the MODS" do
        @mods_rec.term_value(:identifier).should == nil
      end
      it "should return nil if there are only empty values in the MODS" do
        @mods_rec.term_value(:genre).should == nil
      end
      it "should return a String for a single value" do
        @mods_rec.term_value(:abstract).should == 'single'
      end
      it "should return a String containing all values, with separator, for multiple values" do
        @mods_rec.term_value(:note).should == 'mult1 mult2'
      end
      it "should work with an Array of messages passed as the argument" do
        @mods_rec.term_value([:subject, 'topic']).should == 'topic1 topic2 topic3'
      end
      it "should take a separator argument" do
        @mods_rec.term_value(:note, ' -|-').should == 'mult1 -|-mult2'
      end
    end

    context "term_values (multiple values)" do
      it "should return nil if there are no such values in the MODS" do
        @mods_rec.term_values(:identifier).should == nil
      end
      it "should return nil if there are only empty values in the MODS" do
        @mods_rec.term_values(:genre).should == nil
      end
      it "should return an array of size one for a single value" do
        @mods_rec.term_values(:abstract).should == ['single']
      end
      it "should return an array of values for multiple values" do
        @mods_rec.term_values(:note).should == ['mult1', 'mult2']
      end
      it "should work with an Array of messages passed as the argument" do
        @mods_rec.term_values([:subject, 'topic']).should == ['topic1', 'topic2', 'topic3']
      end
      it "should work with a String passed as the argument" do
        @mods_rec.term_values('abstract').should == ['single']
      end
      it "should raise an error for an unrecognized message symbol" do
        expect { @mods_rec.term_values(:not_there) }.to raise_error(ArgumentError, "term_values called with unknown argument: :not_there")
      end
      it "should raise an error if the argument is an Array containing non-symbols" do
        expect { @mods_rec.term_values([:subject, @mods_rec.subject]) }.to raise_error(ArgumentError, /term_values called with Array containing unrecognized class:.*NodeSet.*/)
      end
      it "should raise an error if the argument isn't a Symbol or an Array" do
        expect { @mods_rec.term_values(@mods_rec.subject) }.to raise_error(ArgumentError, /term_values called with unrecognized argument class:.*NodeSet.*/)
      end
    end    
  end # getting term values
  
  context "convenience methods for accessing tricky bits of terminology" do
    before(:all) do
      @mods_rec = Mods::Record.new
    end
    context "title methods" do
      it "short_titles should return an Array of Strings (multiple titles are legal in Mods)" do
        @mods_rec.from_str("<mods #{@def_ns_decl}><titleInfo><title>Jerk</title><nonSort>The</nonSort></titleInfo><titleInfo><title>Joke</title></titleInfo></mods>")
        @mods_rec.short_titles.should == ["The Jerk", "Joke"]
      end
      it "full_titles should return an Array of Strings (multiple titles are legal in Mods)" do
        @mods_rec.from_str("<mods #{@def_ns_decl}><titleInfo><title>Jerk</title><nonSort>The</nonSort></titleInfo><titleInfo><title>Joke</title></titleInfo></mods>")
        @mods_rec.full_titles.should == ["The Jerk", "Joke"]
      end
      it "sort_title should return a String (sortable fields are single valued)" do
        @mods_rec.from_str("<mods #{@def_ns_decl}><titleInfo><title>Jerk</title><subTitle>A Tale of Tourettes</subTitle><nonSort>The</nonSort></titleInfo></mods>")
        @mods_rec.sort_title.should == "Jerk A Tale of Tourettes"
      end
      it "alternative_titles should return an Array of Strings (multiple alternative titles when there are multiple titleInfo elements)" do
        @mods_rec.from_str("<mods #{@def_ns_decl}><titleInfo type='alternative'><title>1</title></titleInfo><titleInfo type='alternative'><title>2</title></titleInfo></mods>")
        @mods_rec.alternative_titles.should == ['1', '2']
        @mods_rec.from_str("<mods #{@def_ns_decl}><titleInfo type='alternative'><title>1</title><title>2</title></titleInfo></mods>")
        @mods_rec.alternative_titles.should == ['12']
      end
    end
    
    context "personal_names" do
      before(:all) do
        @pers_name = 'Crusty'
        @mods_w_pers_name = "<mods #{@def_ns_decl}><name type='personal'><namePart>#{@pers_name}</namePart></name></mods>"
        @pers_role = 'creator'
        @mods_w_pers_name_role = "<mods #{@def_ns_decl}><name type='personal'><namePart>#{@pers_name}</namePart>"
        @given_family = '<mods xmlns="http://www.loc.gov/mods/v3"><name type="personal"><namePart type="given">Jorge Luis</namePart>
                                <namePart type="family">Borges</namePart></name></mods>'        
        @given_family_date = '<mods xmlns="http://www.loc.gov/mods/v3"><name type="personal"><namePart type="given">Zaphod</namePart>
                                <namePart type="family">Beeblebrox</namePart>
                                <namePart type="date">1912-2362</namePart></name></mods>'
        @all_name_parts = '<mods xmlns="http://www.loc.gov/mods/v3"><name type="personal"><namePart type="given">Given</namePart>
                                <namePart type="family">Family</namePart>
                                <namePart type="termsOfAddress">Mr.</namePart>
                                <namePart type="date">date</namePart></name></mods>'
        @family_only = '<mods xmlns="http://www.loc.gov/mods/v3"><name type="personal"><namePart type="family">Family</namePart></name></mods>'
        @given_only = '<mods xmlns="http://www.loc.gov/mods/v3"><name type="personal"><namePart type="given">Given</namePart></name></mods>'
      end

      it "should return an Array of Strings" do
        @mods_rec.from_str(@mods_w_pers_name)
        @mods_rec.personal_names.should == [@pers_name]
      end

      it "should not include the role text" do
        @mods_rec.from_str(@mods_w_pers_name_role)
        @mods_rec.personal_names.first.should_not match(@pers_role)
      end

      it "should prefer displayForm over namePart pieces" do
        display_form_and_name_parts = '<mods xmlns="http://www.loc.gov/mods/v3"><name type="personal"><namePart type="given">Jorge Luis</namePart>
                                <namePart type="family">Borges</namePart>
                                <displayForm>display form</displayForm></name></mods>'        
        @mods_rec.from_str(display_form_and_name_parts)
        @mods_rec.personal_names.should include("display form")
      end

      it "should put the family namePart first" do
        @mods_rec.from_str(@given_family)
        @mods_rec.personal_names.first.should match(/^Borges/)
        @mods_rec.from_str(@given_family_date)
        @mods_rec.personal_names.first.should match(/^Beeblebrox/)
      end
      it "should not include date" do
        @mods_rec.from_str(@given_family_date)
        @mods_rec.personal_names.first.should_not match(/19/)
        @mods_rec.from_str(@all_name_parts)
        @mods_rec.personal_names.first.should_not match('date')
      end
      it "should include a comma when there is both a family and a given name" do
        @mods_rec.from_str(@all_name_parts)
        @mods_rec.personal_names.should include("Family, Given Mr.")
      end
      it "should include multiple words in a namePart" do
        @mods_rec.from_str(@given_family)
        @mods_rec.personal_names.should include("Borges, Jorge Luis")
      end
      it "should not include a comma when there is only a family or given name" do
        [@family_only, @given_only].each { |mods_str|  
          @mods_rec.from_str(mods_str)
          @mods_rec.personal_names.first.should_not match(/,/)
        }
      end
      it "should include terms of address" do
        @mods_rec.from_str(@all_name_parts)
        @mods_rec.personal_names.first.should match(/Mr./)
      end      
    end # personal_names 
    
    context "personal_names_w_dates" do
      before(:all) do
        @given_family = '<mods xmlns="http://www.loc.gov/mods/v3"><name type="personal"><namePart type="given">Jorge Luis</namePart>
                                <namePart type="family">Borges</namePart></name></mods>'        
        @given_family_date = '<mods xmlns="http://www.loc.gov/mods/v3"><name type="personal"><namePart type="given">Zaphod</namePart>
                                <namePart type="family">Beeblebrox</namePart>
                                <namePart type="date">1912-2362</namePart></name></mods>'
        @all_name_parts = '<mods xmlns="http://www.loc.gov/mods/v3"><name type="personal"><namePart type="given">Given</namePart>
                                <namePart type="family">Family</namePart>
                                <namePart type="termsOfAddress">Mr.</namePart>
                                <namePart type="date">date</namePart></name></mods>'
      end
      it "should return an Array of Strings" do
        @mods_rec.from_str(@given_family_date)
        @mods_rec.personal_names_w_dates.should be_an_instance_of(Array)
      end
      it "should include the date when it is available" do
        @mods_rec.from_str(@given_family_date)
        @mods_rec.personal_names_w_dates.first.should match(/, 1912-2362$/)
        @mods_rec.from_str(@all_name_parts)
        @mods_rec.personal_names_w_dates.first.should match(/, date$/)
      end      
      it "should be just the personal_name if no date is available" do
        @mods_rec.from_str(@given_family)
        @mods_rec.personal_names_w_dates.first.should == 'Borges, Jorge Luis'
      end
    end
      
    context "corporate_names" do
      before(:all) do
        @corp_name = 'ABC corp'
      end
      it "should return an Array of Strings" do
        @mods_rec.from_str("<mods #{@def_ns_decl}><name type='corporate'><namePart>#{@corp_name}</namePart></name></mods>")
        @mods_rec.corporate_names.should == [@corp_name]
      end
      it "should not include the role text" do
        corp_role = 'lithographer'
        mods_w_corp_name_role = "<mods #{@def_ns_decl}><name type='corporate'><namePart>#{@corp_name}</namePart>
          <role><roleTerm type='text'>#{corp_role}</roleTerm></role></name></mods>"
        @mods_rec.from_str(mods_w_corp_name_role)      
        @mods_rec.corporate_names.first.should_not match(corp_role)
      end

      it "should prefer displayForm over namePart pieces" do
        display_form_and_name_parts = "<mods #{@def_ns_decl}><name type='corporate'><namePart>Food, Inc.</namePart>
                                <displayForm>display form</displayForm></name></mods>"       
        @mods_rec.from_str(display_form_and_name_parts)
        @mods_rec.corporate_names.should include("display form")
      end
    end # corporate_names
    
    context "languages" do
      before(:all) do
        @simple = "<mods #{@def_ns_decl}><language>Greek</language></mods>"
        @iso639_2b_code = "<mods #{@def_ns_decl}><language><languageTerm authority='iso639-2b' type='code'>fre</languageTerm></language></mods>"
        @iso639_2b_text = "<mods #{@def_ns_decl}><language><languageTerm authority='iso639-2b' type='text'>English</languageTerm></language></mods>"
        @mult_codes = "<mods #{@def_ns_decl}><language><languageTerm authority='iso639-2b' type='code'>per ara, dut</languageTerm></language></mods>"
      end
      it "should translate iso639-2b codes to English" do
        @mods_rec.from_str(@iso639_2b_code)
        @mods_rec.languages.should == ["French"]
      end
      it "should pass thru language values that are already text (not code)" do
        @mods_rec.from_str(@iso639_2b_text)
        @mods_rec.languages.should == ["English"]
      end
      it "should keep values that are not inside <languageTerm> elements" do
        @mods_rec.from_str(@simple)
        @mods_rec.languages.should == ["Greek"]
      end
      it "should create a separate value for each language in a comma, space, or | separated list " do
        @mods_rec.from_str(@mult_codes)
        @mods_rec.languages.should include("Arabic")
        @mods_rec.languages.should include("Persian")
        @mods_rec.languages.should include("Dutch; Flemish")
      end
    end
  end # convenience methods for tricky bits of terminology

end
