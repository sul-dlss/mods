require 'spec_helper'

describe "Mods <subject> Element" do
  before(:all) do
    @mods_rec = Mods::Record.new
  end

  it "should do something intelligent with duplicate values" do
    pending "to be implemented"
  end

  it "should do some date parsing of temporal element based on encoding" do
    pending "to be implemented"
  end
  
  it "authority designation on the <subject> element should trickle down to child elements" do
    pending "to be implemented"
  end
  
  it "should subject personal name dates should be cleaned up???" do
    pending "to be implemented"
  end
  
  it "should translate the geographicCodes" do
    pending "to be implemented"
  end

  context "names" do
    before(:all) do
      @both_types = @mods_rec.from_str('<mods><subject>
                   <name type="personal">
                     <namePart>Bridgens, R.P</namePart>
                   </name>
                 </subject><subject authority="lcsh">
                    <name type="corporate">
                      <namePart>Britton &amp; Rey.</namePart>
                    </name>
                  </subject></mods>').subject.name
      @pers_name = @mods_rec.from_str('<mods><subject>
                  <name type="personal" authority="ingest">
                      <namePart type="family">Edward VI , king of England, </namePart>
                      <displayForm>Edward VI , king of England, 1537-1553</displayForm>
                  </name></subject></mods>').subject.name
      @mult_pers_name = @mods_rec.from_str('<mods><subject authority="lcsh">
                   <name type="personal">
                     <namePart>Baker, George H</namePart>
                     <role>
                       <roleTerm type="text">lithographer.</roleTerm>
                     </role>
                   </name>
                 </subject><subject>
                   <name type="personal">
                     <namePart>Beach, Ghilion</namePart>
                     <role>
                       <roleTerm type="text">publisher.</roleTerm>
                     </role>
                   </name>
                 </subject><subject>
                   <name type="personal">
                     <namePart>Bridgens, R.P</namePart>
                   </name>
                 </subject><subject authority="lcsh">
                   <name type="personal">
                     <namePart>Couts, Cave Johnson</namePart>
                     <namePart type="date">1821-1874</namePart>
                   </name>
                 </subject><subject authority="lcsh">
                   <name type="personal">
                     <namePart>Kuchel, Charles Conrad</namePart>
                     <namePart type="date">b. 1820</namePart>
                   </name>
                 </subject><subject authority="lcsh">
                   <name type="personal">
                     <namePart>Nahl, Charles Christian</namePart>
                     <namePart type="date">1818-1878</namePart>
                   </name>
                 </subject><subject authority="lcsh">
                   <name type="personal">
                     <namePart>Swasey, W. F. (William F.)</namePart>
                   </name></subject></mods>').subject.name
      @mult_corp_name = @mods_rec.from_str('<mods><subject authority="lcsh">
                   <name type="corporate">
                     <namePart>Britton &amp; Rey.</namePart>
                   </name>
                 </subject><subject>
                   <name type="corporate">
                     <namePart>Gray (W. Vallance) &amp; C.B. Gifford,</namePart>
                     <role>
                       <roleTerm type="text">lithographers.</roleTerm>
                     </role>
                   </name></subject></mods>').subject.name
    end
    it "should be able to identify corporate names" do
      pending "to be implemented"
    end
    it "should be able to identify personal names" do
      pending "to be implemented"
    end
    it "should be able to identify roles associated with a name" do
      pending "to be implemented"
    end
    it "should be able to identify dates associated with a name" do
      pending "to be implemented"
    end
    it "should do the appropriate thing with the role for the value of a name" do
      pending "to be implemented"
    end
    it "should do the appropriate thing with the date for the value of a name" do
      pending "to be implemented"
    end
  end

  context "basic subject terminology pieces" do
    before(:all) do
      @four_subjects = @mods_rec.from_str('<mods><subject authority="lcsh">
           <geographic>San Francisco (Calif.)</geographic>
           <topic>History</topic>
           <genre>Pictorial works</genre>
         </subject>
         <subject authority="lcsh">
           <geographic>San Diego (Calif.)</geographic>
           <topic>History</topic>
           <genre>Pictorial works</genre>
         </subject>
         <subject authority="lcsh">
           <topic>History</topic>
           <genre>Pictorial works</genre>
         </subject>
         <subject authority="lcsh">
           <geographic>San Luis Rey (Calif.)</geographic>
           <genre>Pictorial works</genre>
         </subject></mods>').subject
      @geo_code_subject = @mods_rec.from_str('<mods><subject>
                <geographicCode authority="marcgac">f------</geographicCode></subject></mods>').subject
      @lcsh_subject = @mods_rec.from_str('<mods><subject authority="lcsh">
                <geographic>Africa</geographic>
                <genre>Maps</genre>
                <temporal>500-1400</temporal></subject></mods>').subject              
    end
    
    it "should be a NodeSet" do
      @four_subjects.should be_an_instance_of(Nokogiri::XML::NodeSet)
      @lcsh_subject.should be_an_instance_of(Nokogiri::XML::NodeSet)
    end
    it "should have as many members as there are <subject> elements in the xml" do
      @four_subjects.size.should == 4
      @lcsh_subject.size.should == 1
    end
    it "should recognize authority attribute on <subject> element" do
      ['lcsh', 'ingest', 'lctgm'].each { |a| 
        @mods_rec.from_str("<mods><subject authority='#{a}'><topic>Ruler, English.</topic></subject></mods>").subject.authority.should == [a]
      }
    end
    
    context "<topic> child element" do
      before(:all) do
        topic = '<mods><subject authority="lcsh"><topic>History</topic></subject></mods>'
        @topic_simple = @mods_rec.from_str(topic).subject.topic
        multi_topic = '<mods><subject>
              <topic>California as an island--Maps--1662?</topic>
              <topic>North America--Maps--To 1800</topic>
              <topic>North America--Maps--1662?</topic>
            </subject></mods>'
        @multi_topic = @mods_rec.from_str(multi_topic).subject.topic
      end
      it "should be a NodeSet" do
        @topic_simple.should be_an_instance_of(Nokogiri::XML::NodeSet)
        @multi_topic.should be_an_instance_of(Nokogiri::XML::NodeSet)
      end
      it "topic NodeSet should have as many Nodes as there are <topic> elements in the xml" do
        @topic_simple.size.should == 1
        @multi_topic.size.should == 3
        @four_subjects.topic.size.should == 3
        @geo_code_subject.topic.size.should == 0
      end
      it "text should get element value" do
        @topic_simple.text.should == "History"
        @multi_topic.text.should include("California as an island--Maps--1662?")
        @multi_topic.text.should include("North America--Maps--To 1800")
        @multi_topic.text.should include("North America--Maps--1662?")
        @four_subjects.topic.text.should include("History")
      end
    end # <topic>
    
    context "<geographic> child element" do
      it "should be a NodeSet" do
        @four_subjects.geographic.should be_an_instance_of(Nokogiri::XML::NodeSet)
        @lcsh_subject.geographic.should be_an_instance_of(Nokogiri::XML::NodeSet)
        @geo_code_subject.geographic.should be_an_instance_of(Nokogiri::XML::NodeSet)
      end
      it "geographic NodeSet should have as many Nodes as there are <geographic> elements in the xml" do
        @four_subjects.geographic.size.should == 3
        @lcsh_subject.geographic.size.should == 1
        @geo_code_subject.geographic.size.should == 0
      end
      it "text should get element value" do
        @four_subjects.geographic.text.should include("San Francisco (Calif.)")
        @four_subjects.geographic.text.should include("San Diego (Calif.)")
        @four_subjects.geographic.text.should include("San Luis Rey (Calif.)")
      end
      it "should not include <geographicCode> element" do
        @geo_code_subject.geographic.size.should == 0
      end
    end # <geographic>
    
    context "<temporal> child element" do
      before(:all) do
        @temporal = @mods_rec.from_str('<mods><subject>
                  <temporal encoding="iso8601">20010203T040506+0700</temporal>
                  <!-- <temporal encoding="iso8601">197505</temporal> -->
                </subject></mods>').subject.temporal        
      end
      
      it "should recognize the date attributes" do
        @temporal.encoding.should == ['iso8601']
        Mods::DATE_ATTRIBS.each { |a| 
          @mods_rec.from_str("<mods><subject><temporal #{a}='val'>now</temporal></subject></mods>").subject.temporal.send(a.to_sym).should == ['val']
        }
      end
      it "should be a NodeSet" do
        @lcsh_subject.temporal.should be_an_instance_of(Nokogiri::XML::NodeSet)
        @temporal.should be_an_instance_of(Nokogiri::XML::NodeSet)
      end
      it "temporal NodeSet should have as many Nodes as there are <temporal> elements in the xml" do
        @lcsh_subject.temporal.size.should == 1
        @temporal.size.should == 1
      end
      it "text should get element value" do
        @lcsh_subject.temporal.map { |n| n.text }.should == ['500-1400']
        @temporal.map { |n| n.text }.should == ['20010203T040506+0700']
      end
    end # <temporal>
    
    context "<genre> child element" do
      it "should be a NodeSet" do
        @lcsh_subject.genre.should be_an_instance_of(Nokogiri::XML::NodeSet)
        @four_subjects.genre.should be_an_instance_of(Nokogiri::XML::NodeSet)
      end
      it "genre NodeSet should have as many Nodes as there are <genre> elements in the xml" do
        @lcsh_subject.genre.size.should == 1
        @four_subjects.genre.size.should == 4
      end
      it "text should get element value" do
        @lcsh_subject.genre.map { |n| n.text }.should == ['Maps']
        @four_subjects.genre.map { |n| n.text }.should include("Pictorial works")
      end
    end # <genre>
    
    context "<geographicCode> child element" do
      it "should be a NodeSet" do
        @geo_code_subject.geographicCode.should be_an_instance_of(Nokogiri::XML::NodeSet)
      end
      it "cartographics NodeSet should have as many Nodes as there are <geographicCode> elements in the xml" do
        @geo_code_subject.geographicCode.size.should == 1
      end
      it "text should get element value" do
        @geo_code_subject.geographicCode.map { |n| n.text }.should == ['f------']
      end
      it "should recognize authority attributes" do
        Mods::AUTHORITY_ATTRIBS.each { |a|  
          @mods_rec.from_str("<mods><subject><geographicCode #{a}='attr_val'>f------</geographicCode></subject></mods>")
          @mods_rec.subject.geographicCode.send(a.to_sym).should == ['attr_val']
        }
      end
      it "should recognize the sanctioned authorities" do
        Mods::Subject::GEO_CODE_AUTHORITIES.each { |a|  
          @mods_rec.from_str("<mods><subject><geographicCode authority='#{a}'>f------</geographicCode></subject></mods>")
          @mods_rec.subject.geographicCode.authority.should == [a]
        }
      end
      it "should not recognize unsanctioned authorities?" do
        @mods_rec.from_str("<mods><subject><geographicCode authority='fake'>f------</geographicCode></subject></mods>")
        pending "to be implemented"
        expect { @mods_rec.subject.geographicCode.authority }.to raise_error(/no idea/)
      end    
    end # <geographicCode>
    
    context "<titleInfo> child element" do
      before(:all) do
        @title_info = @mods_rec.from_str('<mods><subject>
          <titleInfo>
            <nonSort>The</nonSort>
            <title>Olympics</title>
            <subTitle>a history</subTitle>
          </titleInfo>
        </subject></mods>').subject.titleInfo
      end
      it "should understand all attributes allowed on a <titleInfo> element" do
        Mods::TitleInfo::ATTRIBUTES.each { |a|
          ti = @mods_rec.from_str("<mods><subject><titleInfo #{a}='attr_val'>THE</titleInfo></subject></mods>").subject.titleInfo
          if (a == 'type')
            ti.type_at.should == ['attr_val']
          else
            ti.send(a.to_sym).should == ['attr_val']
          end
        }
      end
      it "should understand all immediate child elements allowed on a <titleInfo> element" do
        Mods::TitleInfo::CHILD_ELEMENTS.each { |e|  
          @mods_rec.from_str("<mods><subject><titleInfo><#{e}>el_val</#{e}></titleInfo></subject></mods>").subject.titleInfo.send(e.to_sym).text.should == 'el_val'
        }
        @title_info.nonSort.map {|n| n.text}.should == ["The"]
      end
      
      it "should recognize authority attribute on the <titleInfo> element" do
        @mods_rec.from_str('<mods><subject>
          	<titleInfo type="uniform" authority="naf">
          	  	<title>Missale Carnotense</title>
          	</titleInfo></subject></mods>').subject.titleInfo.authority.should == ["naf"]
      end
    end # <titleInfo>
    
    context "<name> child element" do
      it "should understand all attributes allowed on a <name> element" do
        Mods::Name::ATTRIBUTES.each { |a|
          name = @mods_rec.from_str("<mods><subject><name #{a}='attr_val'>Obadiah</name></subject></mods>").subject.name_
          if (a == 'type')
            name.type_at.should == ['attr_val']
          else
            name.send(a.to_sym).should == ['attr_val']
          end
        }
      end
      it "should understand all immediate child elements allowed on a <name> element" do
        Mods::Name::CHILD_ELEMENTS.each { |e|  
          name = @mods_rec.from_str("<mods><subject><name><#{e}>el_val</#{e}></name></subject></mods>").subject.name_
          if (e == 'description')
            name.description_el.text.should == 'el_val'
          elsif (e != 'role')
            name.send(e.to_sym).text.should == 'el_val'
          end
        }
      end
      it "should recognize authority attribute on the <name> element" do
        @mods_rec.from_str('<mods><subject>
           <name type="personal" authority="lcsh">
             <namePart>Nahl, Charles Christian</namePart>
             <namePart type="date">1818-1878</namePart>
           </name></mods>').subject.name_.authority.should == ["lcsh"]
      end
    end # <name>
     
    context "<hiearchicalGeographic> child element" do
      it "should recognize authority attributes" do
        Mods::AUTHORITY_ATTRIBS.each { |a|  
          @mods_rec.from_str("<mods><subject><hierarchicalGeographic #{a}='attr_val'><country>Albania</country></hierarchicalGeographic></subject></mods>")
          @mods_rec.subject.hierarchicalGeographic.send(a.to_sym).should == ['attr_val']
        }
      end
      it "should recognize allowed child elements" do
        Mods::Subject::HIER_GEO_CHILD_ELEMENTS.each { |e|  
          @mods_rec.from_str("<mods><subject><hierarchicalGeographic><#{e}>el_val</#{e}></hierarchicalGeographic></subject></mods>")
          @mods_rec.subject.hierarchicalGeographic.send(e.to_sym).text.should == 'el_val'
        }
        Mods::Subject::HIER_GEO_CHILD_ELEMENTS.size.should == 12
      end
    end # <hierarchicalGeographic>
    
    context "<cartographics> child element" do
      before(:all) do
        @carto_scale = @mods_rec.from_str('<mods><subject>
                  <cartographics>
                    <scale>[ca.1:90,000,000], [173</scale>
                  </cartographics>
                </subject></mods>').subject.cartographics
        @carto_empties = @mods_rec.from_str('<mods><subject authority="">
                   <cartographics>
                     <scale/>
                     <coordinates>W1730000 W0100000 N840000 N071000</coordinates>
                     <projection/>
                   </cartographics>
                 </subject></mods>').subject.cartographics
        @multi_carto = @mods_rec.from_str('<mods><subject>
                    <cartographics>
                       <coordinates>W0180000 E0510000 N370000 S350000</coordinates>
                    </cartographics>
                 </subject><subject>
                    <cartographics>
                       <scale>Scale [ca. 1:50,000,000]</scale>
                    </cartographics>
                    <cartographics>
                       <coordinates>(W18&#xB0;--E51&#xB0;/N37&#xB0;--S35&#xB0;).</coordinates>
                    </cartographics>
                 </subject></mods>').subject.cartographics
      end
      it "should be a NodeSet" do
        @carto_scale.should be_an_instance_of(Nokogiri::XML::NodeSet)
        @carto_empties.should be_an_instance_of(Nokogiri::XML::NodeSet)
        @multi_carto.should be_an_instance_of(Nokogiri::XML::NodeSet)
      end
      it "cartographics NodeSet should have as many Nodes as there are <cartographics> elements in the xml" do
        @carto_scale.size.should == 1
        @carto_empties.size.should == 1
        @multi_carto.size.should == 3
      end
      it "should recognize allowed child elements" do
        Mods::Subject::CARTOGRAPHICS_CHILD_ELEMENTS.each { |e|  
          @mods_rec.from_str("<mods><subject><cartographics><#{e}>el_val</#{e}></cartographics></subject></mods>")
          @mods_rec.subject.cartographics.send(e.to_sym).text.should == 'el_val'
        }
        Mods::Subject::CARTOGRAPHICS_CHILD_ELEMENTS.size.should == 3
      end
      it "should get the number of populated <coordinates> elements for coordinates term" do
        @multi_carto.coordinates.size == 2
      end
      it "should be able to get the value of populated elements" do
        @carto_scale.scale.map { |n| n.text }.should == ['[ca.1:90,000,000], [173']
        @carto_empties.coordinates.map { |n| n.text }.should == ['W1730000 W0100000 N840000 N071000']
      end
      it "should get the empty string for empty elements?" do
        @carto_empties.projection.map { |n| n.text }.should == ['']
      end
    end # <cartographics>
    
    context "<occupation> child element" do
      before(:all) do
        @occupation = @mods_rec.from_str('<mods><subject><occupation>Migrant laborers</occupation></mods>').subject.occupation
      end
      it "should be a NodeSet" do
        @occupation.should be_an_instance_of(Nokogiri::XML::NodeSet)
      end
      it "occupation NodeSet should have as many Nodes as there are <occupation> elements in the xml" do
        @occupation.size.should == 1
      end
      it "text should get element value" do
        @occupation.map { |n| n.text }.should == ['Migrant laborers']
      end
      it "should recognize authority attributes" do
        Mods::AUTHORITY_ATTRIBS.each { |a|  
          @mods_rec.from_str("<mods><subject><occupation #{a}='attr_val'>Flunkie</occupation></subject></mods>")
          @mods_rec.subject.occupation.send(a.to_sym).should == ['attr_val']
        }
      end
      
    end # <occupation>
    
  end # basic subject terminology
  
end