# encoding: UTF-8

require 'spec_helper'

describe "Mods <subject> Element" do
  before(:all) do
    @mods_rec = Mods::Record.new
    @ns_decl = "xmlns='#{Mods::MODS_NS}'"
  end

  context "subterms for <name> child elements of <subject> element" do
    before(:all) do
      @both_types_sub = @mods_rec.from_str("<mods #{@ns_decl}><subject>
                   <name type='personal'>
                     <namePart>Bridgens, R.P</namePart>
                   </name>
                 </subject><subject authority='lcsh'>
                    <name type='corporate'>
                      <namePart>Britton &amp; Rey.</namePart>
                    </name>
                  </subject></mods>").subject
      @pers_name_sub = @mods_rec.from_str("<mods #{@ns_decl}><subject>
                  <name type='personal' authority='ingest'>
                      <namePart type='family'>Edward VI , king of England, </namePart>
                      <displayForm>Edward VI , king of England, 1537-1553</displayForm>
                  </name></subject></mods>").subject
      @mult_pers_name_sub = @mods_rec.from_str("<mods #{@ns_decl}><subject authority='lcsh'>
                   <name type='personal'>
                     <namePart>Baker, George H</namePart>
                     <role>
                       <roleTerm type='text'>lithographer.</roleTerm>
                     </role>
                   </name>
                 </subject><subject>
                   <name type='personal'>
                     <namePart>Beach, Ghilion</namePart>
                     <role>
                       <roleTerm type='text'>publisher.</roleTerm>
                     </role>
                   </name>
                 </subject><subject>
                   <name type='personal'>
                     <namePart>Bridgens, R.P</namePart>
                   </name>
                 </subject><subject authority='lcsh'>
                   <name type='personal'>
                     <namePart>Couts, Cave Johnson</namePart>
                     <namePart type='date'>1821-1874</namePart>
                   </name>
                 </subject><subject authority='lcsh'>
                   <name type='personal'>
                     <namePart>Kuchel, Charles Conrad</namePart>
                     <namePart type='date'>b. 1820</namePart>
                   </name>
                 </subject><subject authority='lcsh'>
                   <name type='personal'>
                     <namePart>Nahl, Charles Christian</namePart>
                     <namePart type='date'>1818-1878</namePart>
                   </name>
                 </subject><subject authority='lcsh'>
                   <name type='personal'>
                     <namePart>Swasey, W. F. (William F.)</namePart>
                   </name></subject></mods>").subject
      @mult_corp_name_sub = @mods_rec.from_str("<mods #{@ns_decl}><subject authority='lcsh'>
                   <name type='corporate'>
                     <namePart>Britton &amp; Rey.</namePart>
                   </name>
                 </subject><subject>
                   <name type='corporate'>
                     <namePart>Gray (W. Vallance) &amp; C.B. Gifford,</namePart>
                     <role>
                       <roleTerm type='text'>lithographers.</roleTerm>
                     </role>
                   </name></subject></mods>").subject
    end
    it "should be able to identify corporate names" do
      expect(@both_types_sub.corporate_name.namePart.map { |e| e.text }).to eq(['Britton & Rey.'])
    end
    it "should be able to identify personal names" do
      expect(@both_types_sub.personal_name.namePart.map { |e| e.text }).to eq(['Bridgens, R.P'])
      expect(@pers_name_sub.personal_name.displayForm.map { |e| e.text }).to eq(['Edward VI , king of England, 1537-1553'])
    end
    it "should be able to identify roles associated with a name" do
      expect(@mult_corp_name_sub.corporate_name.role.roleTerm.map { |e| e.text }).to eq(['lithographers.'])
    end
    it "should be able to identify dates associated with a name" do
      expect(@mult_pers_name_sub.personal_name.date.map { |e| e.text }).to include("1818-1878")
    end
  end

  context "basic subject terminology pieces" do

    context "WITH namespaces" do
      before(:all) do
        @four_subjects = @mods_rec.from_str("<mods #{@ns_decl}><subject authority='lcsh'>
             <geographic>San Francisco (Calif.)</geographic>
             <topic>History</topic>
             <genre>Pictorial works</genre>
           </subject>
           <subject authority='lcsh'>
             <geographic>San Diego (Calif.)</geographic>
             <topic>History</topic>
             <genre>Pictorial works</genre>
           </subject>
           <subject authority='lcsh'>
             <topic>History</topic>
             <genre>Pictorial works</genre>
           </subject>
           <subject authority='lcsh'>
             <geographic>San Luis Rey (Calif.)</geographic>
             <genre>Pictorial works</genre>
           </subject></mods>").subject
        @geo_code_subject = @mods_rec.from_str("<mods #{@ns_decl}><subject>
                  <geographicCode authority='marcgac'>f------</geographicCode></subject></mods>").subject
        @lcsh_subject = @mods_rec.from_str("<mods #{@ns_decl}><subject authority='lcsh'>
                  <geographic>Africa</geographic>
                  <genre>Maps</genre>
                  <temporal>500-1400</temporal></subject></mods>").subject
      end

      it "should be a NodeSet" do
        expect(@four_subjects).to be_an_instance_of(Nokogiri::XML::NodeSet)
        expect(@lcsh_subject).to be_an_instance_of(Nokogiri::XML::NodeSet)
      end
      it "should have as many members as there are <subject> elements in the xml" do
        expect(@four_subjects.size).to eq(4)
        expect(@lcsh_subject.size).to eq(1)
      end
      it "should recognize authority attribute on <subject> element" do
        ['lcsh', 'ingest', 'lctgm'].each { |a|
          expect(@mods_rec.from_str("<mods #{@ns_decl}><subject authority='#{a}'><topic>Ruler, English.</topic></subject></mods>").subject.authority).to eq([a])
        }
      end

      context "<topic> child element" do
        before(:all) do
          topic = "<mods #{@ns_decl}><subject authority='lcsh'><topic>History</topic></subject></mods>"
          @topic_simple = @mods_rec.from_str(topic).subject.topic
          multi_topic = "<mods #{@ns_decl}><subject>
                <topic>California as an island--Maps--1662?</topic>
                <topic>North America--Maps--To 1800</topic>
                <topic>North America--Maps--1662?</topic>
              </subject></mods>"
          @multi_topic = @mods_rec.from_str(multi_topic).subject.topic
        end
        it "should be a NodeSet" do
          expect(@topic_simple).to be_an_instance_of(Nokogiri::XML::NodeSet)
          expect(@multi_topic).to be_an_instance_of(Nokogiri::XML::NodeSet)
        end
        it "topic NodeSet should have as many Nodes as there are <topic> elements in the xml" do
          expect(@topic_simple.size).to eq(1)
          expect(@multi_topic.size).to eq(3)
          expect(@four_subjects.topic.size).to eq(3)
          expect(@geo_code_subject.topic.size).to eq(0)
        end
        it "text should get element value" do
          expect(@topic_simple.text).to eq("History")
          expect(@multi_topic.text).to include("California as an island--Maps--1662?")
          expect(@multi_topic.text).to include("North America--Maps--To 1800")
          expect(@multi_topic.text).to include("North America--Maps--1662?")
          expect(@four_subjects.topic.text).to include("History")
        end
      end # <topic>

      context "<geographic> child element" do
        it "should be a NodeSet" do
          expect(@four_subjects.geographic).to be_an_instance_of(Nokogiri::XML::NodeSet)
          expect(@lcsh_subject.geographic).to be_an_instance_of(Nokogiri::XML::NodeSet)
          expect(@geo_code_subject.geographic).to be_an_instance_of(Nokogiri::XML::NodeSet)
        end
        it "geographic NodeSet should have as many Nodes as there are <geographic> elements in the xml" do
          expect(@four_subjects.geographic.size).to eq(3)
          expect(@lcsh_subject.geographic.size).to eq(1)
          expect(@geo_code_subject.geographic.size).to eq(0)
        end
        it "text should get element value" do
          expect(@four_subjects.geographic.text).to include("San Francisco (Calif.)")
          expect(@four_subjects.geographic.text).to include("San Diego (Calif.)")
          expect(@four_subjects.geographic.text).to include("San Luis Rey (Calif.)")
        end
        it "should not include <geographicCode> element" do
          expect(@geo_code_subject.geographic.size).to eq(0)
        end
      end # <geographic>

      context "<temporal> child element" do
        before(:all) do
          @temporal = @mods_rec.from_str("<mods #{@ns_decl}><subject>
                    <temporal encoding='iso8601'>20010203T040506+0700</temporal>
                    <!-- <temporal encoding='iso8601'>197505</temporal> -->
                  </subject></mods>").subject.temporal
        end

        it "should recognize the date attributes" do
          expect(@temporal.encoding).to eq(['iso8601'])
          Mods::DATE_ATTRIBS.each { |a|
            expect(@mods_rec.from_str("<mods #{@ns_decl}><subject><temporal #{a}='val'>now</temporal></subject></mods>").subject.temporal.send(a.to_sym)).to eq(['val'])
          }
        end
        it "should be a NodeSet" do
          expect(@lcsh_subject.temporal).to be_an_instance_of(Nokogiri::XML::NodeSet)
          expect(@temporal).to be_an_instance_of(Nokogiri::XML::NodeSet)
        end
        it "temporal NodeSet should have as many Nodes as there are <temporal> elements in the xml" do
          expect(@lcsh_subject.temporal.size).to eq(1)
          expect(@temporal.size).to eq(1)
        end
        it "text should get element value" do
          expect(@lcsh_subject.temporal.map { |n| n.text }).to eq(['500-1400'])
          expect(@temporal.map { |n| n.text }).to eq(['20010203T040506+0700'])
        end
      end # <temporal>

      context "<genre> child element" do
        it "should be a NodeSet" do
          expect(@lcsh_subject.genre).to be_an_instance_of(Nokogiri::XML::NodeSet)
          expect(@four_subjects.genre).to be_an_instance_of(Nokogiri::XML::NodeSet)
        end
        it "genre NodeSet should have as many Nodes as there are <genre> elements in the xml" do
          expect(@lcsh_subject.genre.size).to eq(1)
          expect(@four_subjects.genre.size).to eq(4)
        end
        it "text should get element value" do
          expect(@lcsh_subject.genre.map { |n| n.text }).to eq(['Maps'])
          expect(@four_subjects.genre.map { |n| n.text }).to include("Pictorial works")
        end
      end # <genre>

      context "<geographicCode> child element" do
        it "should be a NodeSet" do
          expect(@geo_code_subject.geographicCode).to be_an_instance_of(Nokogiri::XML::NodeSet)
        end
        it "cartographics NodeSet should have as many Nodes as there are <geographicCode> elements in the xml" do
          expect(@geo_code_subject.geographicCode.size).to eq(1)
        end
        it "text should get element value" do
          expect(@geo_code_subject.geographicCode.map { |n| n.text }).to eq(['f------'])
        end
        it "should recognize authority attributes" do
          Mods::AUTHORITY_ATTRIBS.each { |a|
            @mods_rec.from_str("<mods #{@ns_decl}><subject><geographicCode #{a}='attr_val'>f------</geographicCode></subject></mods>")
            expect(@mods_rec.subject.geographicCode.send(a.to_sym)).to eq(['attr_val'])
          }
        end
        it "should recognize the sanctioned authorities" do
          Mods::Subject::GEO_CODE_AUTHORITIES.each { |a|
            @mods_rec.from_str("<mods #{@ns_decl}><subject><geographicCode authority='#{a}'>f------</geographicCode></subject></mods>")
            expect(@mods_rec.subject.geographicCode.authority).to eq([a])
          }
        end
        context "translated_value convenience method" do
          it "should be the translation of the code if it is a marcgac code" do
            @mods_rec.from_str("<mods #{@ns_decl}><subject><geographicCode authority='marcgac'>e-er</geographicCode></subject></mods>")
            expect(@mods_rec.subject.geographicCode.translated_value).to eq(["Estonia"])
          end
          it "should be the translation of the code if it is a marccountry code" do
            @mods_rec.from_str("<mods #{@ns_decl}><subject><geographicCode authority='marccountry'>mg</geographicCode></subject></mods>")
            expect(@mods_rec.subject.geographicCode.translated_value).to eq(["Madagascar"])
          end
          it "should be nil if the code is invalid" do
            @mods_rec.from_str("<mods #{@ns_decl}><subject><geographicCode authority='marcgac'>zzz</geographicCode></subject></mods>")
            expect(@mods_rec.subject.geographicCode.translated_value.size).to eq(0)
          end
          it "should be nil if we don't have a translation for the authority" do
            @mods_rec.from_str("<mods #{@ns_decl}><subject><geographicCode authority='iso3166'>zzz</geographicCode></subject></mods>")
            expect(@mods_rec.subject.geographicCode.translated_value.size).to eq(0)
          end
          it "should work with non-ascii characters" do
            @mods_rec.from_str("<mods #{@ns_decl}><subject><geographicCode authority='marccountry'>co</geographicCode></subject></mods>")
            expect(@mods_rec.subject.geographicCode.translated_value).to eq(["Curaçao"])
          end
        end
      end # <geographicCode>

      context "<titleInfo> child element" do
        before(:all) do
          @title_info = @mods_rec.from_str("<mods #{@ns_decl}><subject>
            <titleInfo>
              <nonSort>The</nonSort>
              <title>Olympics</title>
              <subTitle>a history</subTitle>
            </titleInfo>
          </subject></mods>").subject.titleInfo
        end
        it "should understand all attributes allowed on a <titleInfo> element" do
          Mods::TitleInfo::ATTRIBUTES.each { |a|
            ti = @mods_rec.from_str("<mods #{@ns_decl}><subject><titleInfo #{a}='attr_val'>THE</titleInfo></subject></mods>").subject.titleInfo
            if (a == 'type')
              expect(ti.type_at).to eq(['attr_val'])
            else
              expect(ti.send(a.to_sym)).to eq(['attr_val'])
            end
          }
        end
        it "should understand all immediate child elements allowed on a <titleInfo> element" do
          Mods::TitleInfo::CHILD_ELEMENTS.each { |e|
            expect(@mods_rec.from_str("<mods #{@ns_decl}><subject><titleInfo><#{e}>el_val</#{e}></titleInfo></subject></mods>").subject.titleInfo.send(e.to_sym).text).to eq('el_val')
          }
          expect(@title_info.nonSort.map {|n| n.text}).to eq(["The"])
        end

        it "should recognize authority attribute on the <titleInfo> element" do
          expect(@mods_rec.from_str("<mods #{@ns_decl}><subject>
            	<titleInfo type='uniform' authority='naf'>
            	  	<title>Missale Carnotense</title>
            	</titleInfo></subject></mods>").subject.titleInfo.authority).to eq(["naf"])
        end
      end # <titleInfo>

      context "<name> child element" do
        it "should understand all attributes allowed on a <name> element" do
          Mods::Name::ATTRIBUTES.each { |a|
            name = @mods_rec.from_str("<mods #{@ns_decl}><subject><name #{a}='attr_val'>Obadiah</name></subject></mods>").subject.name_el
            if (a == 'type')
              expect(name.type_at).to eq(['attr_val'])
            else
              expect(name.send(a.to_sym)).to eq(['attr_val'])
            end
          }
        end
        it "should understand all immediate child elements allowed on a <name> element" do
          Mods::Name::CHILD_ELEMENTS.each { |e|
            name = @mods_rec.from_str("<mods #{@ns_decl}><subject><name><#{e}>el_val</#{e}></name></subject></mods>").subject.name_el
            if (e == 'description')
              expect(name.description_el.text).to eq('el_val')
            elsif (e != 'role')
              expect(name.send(e.to_sym).text).to eq('el_val')
            end
          }
        end
        it "should recognize authority attribute on the <name> element" do
          expect(@mods_rec.from_str("<mods #{@ns_decl}><subject>
             <name type='personal' authority='lcsh'>
               <namePart>Nahl, Charles Christian</namePart>
               <namePart type='date'>1818-1878</namePart>
             </name></mods>").subject.name_el.authority).to eq(["lcsh"])
        end
      end # <name>

      context "<hiearchicalGeographic> child element" do
        it "should recognize authority attributes" do
          Mods::AUTHORITY_ATTRIBS.each { |a|
            @mods_rec.from_str("<mods #{@ns_decl}><subject><hierarchicalGeographic #{a}='attr_val'><country>Albania</country></hierarchicalGeographic></subject></mods>")
            expect(@mods_rec.subject.hierarchicalGeographic.send(a.to_sym)).to eq(['attr_val'])
          }
        end
        it "should recognize allowed child elements" do
          Mods::Subject::HIER_GEO_CHILD_ELEMENTS.each { |e|
            @mods_rec.from_str("<mods #{@ns_decl}><subject><hierarchicalGeographic><#{e}>el_val</#{e}></hierarchicalGeographic></subject></mods>")
            expect(@mods_rec.subject.hierarchicalGeographic.send(e.to_sym).text).to eq('el_val')
          }
          expect(Mods::Subject::HIER_GEO_CHILD_ELEMENTS.size).to eq(12)
        end
      end # <hierarchicalGeographic>

      context "<cartographics> child element" do
        before(:all) do
          @carto_scale = @mods_rec.from_str("<mods #{@ns_decl}><subject>
                    <cartographics>
                      <scale>[ca.1:90,000,000], [173</scale>
                    </cartographics>
                  </subject></mods>").subject.cartographics
          @carto_empties = @mods_rec.from_str("<mods #{@ns_decl}><subject authority=''>
                     <cartographics>
                       <scale/>
                       <coordinates>W1730000 W0100000 N840000 N071000</coordinates>
                       <projection/>
                     </cartographics>
                   </subject></mods>").subject.cartographics
          @multi_carto = @mods_rec.from_str("<mods #{@ns_decl}><subject>
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
                   </subject></mods>").subject.cartographics
        end
        it "should be a NodeSet" do
          expect(@carto_scale).to be_an_instance_of(Nokogiri::XML::NodeSet)
          expect(@carto_empties).to be_an_instance_of(Nokogiri::XML::NodeSet)
          expect(@multi_carto).to be_an_instance_of(Nokogiri::XML::NodeSet)
        end
        it "cartographics NodeSet should have as many Nodes as there are <cartographics> elements in the xml" do
          expect(@carto_scale.size).to eq(1)
          expect(@carto_empties.size).to eq(1)
          expect(@multi_carto.size).to eq(3)
        end
        it "should recognize allowed child elements" do
          Mods::Subject::CARTOGRAPHICS_CHILD_ELEMENTS.each { |e|
            @mods_rec.from_str("<mods #{@ns_decl}><subject><cartographics><#{e}>el_val</#{e}></cartographics></subject></mods>")
            expect(@mods_rec.subject.cartographics.send(e.to_sym).text).to eq('el_val')
          }
          expect(Mods::Subject::CARTOGRAPHICS_CHILD_ELEMENTS.size).to eq(3)
        end
        it "should get the number of populated <coordinates> elements for coordinates term" do
          @multi_carto.coordinates.size == 2
        end
        it "should be able to get the value of populated elements" do
          expect(@carto_scale.scale.map { |n| n.text }).to eq(['[ca.1:90,000,000], [173'])
          expect(@carto_empties.coordinates.map { |n| n.text }).to eq(['W1730000 W0100000 N840000 N071000'])
        end
        it "should get the empty string for empty elements?" do
          expect(@carto_empties.projection.map { |n| n.text }).to eq([''])
        end
      end # <cartographics>

      context "<occupation> child element" do
        before(:all) do
          @occupation = @mods_rec.from_str("<mods #{@ns_decl}><subject><occupation>Migrant laborers</occupation></mods>").subject.occupation
        end
        it "should be a NodeSet" do
          expect(@occupation).to be_an_instance_of(Nokogiri::XML::NodeSet)
        end
        it "occupation NodeSet should have as many Nodes as there are <occupation> elements in the xml" do
          expect(@occupation.size).to eq(1)
        end
        it "text should get element value" do
          expect(@occupation.map { |n| n.text }).to eq(['Migrant laborers'])
        end
        it "should recognize authority attributes" do
          Mods::AUTHORITY_ATTRIBS.each { |a|
            @mods_rec.from_str("<mods #{@ns_decl}><subject><occupation #{a}='attr_val'>Flunkie</occupation></subject></mods>")
            expect(@mods_rec.subject.occupation.send(a.to_sym)).to eq(['attr_val'])
          }
        end
      end # <occupation>
    end # WITH namespaces
  end # basic subject terminology

end
