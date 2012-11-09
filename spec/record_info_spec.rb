require 'spec_helper'

describe "Mods <recordInfo> Element" do
  before(:all) do
    @mods_rec = Mods::Record.new
  end

  it "should translate language codes" do
    pending "to be implemented"
  end
  
  it "should normalize dates" do
    pending "to be implemented"
  end
  
  context "basic <record_info> terminology pieces" do
    before(:all) do
      @rec_info = @mods_rec.from_str('<mods><recordInfo>
                <recordContentSource authority="marcorg">RQE</recordContentSource>
                <recordCreationDate encoding="marc">890517</recordCreationDate>
                <recordIdentifier source="SIRSI">a9079953</recordIdentifier>
             </recordInfo></mods>').record_info
      @rec_info2 = @mods_rec.from_str('<mods><recordInfo>
                 <descriptionStandard>aacr2</descriptionStandard>
                 <recordContentSource authority="marcorg">AU@</recordContentSource>
                 <recordCreationDate encoding="marc">050921</recordCreationDate>
                 <recordIdentifier source="SIRSI">a8837534</recordIdentifier>
                 <languageOfCataloging>
                    <languageTerm authority="iso639-2b" type="code">eng</languageTerm>
                 </languageOfCataloging>
             </recordInfo></mods>').record_info
      @bnf = @mods_rec.from_str('<mods><recordInfo>
                  <recordContentSource>TEI Description</recordContentSource>
                  <recordCreationDate encoding="w3cdtf">2011-12-07</recordCreationDate>
                  <recordIdentifier source="BNF 2166"/>
                  <recordOrigin/>
                  <languageOfCataloging>
                      <languageTerm authority="iso639-2b">fra</languageTerm>
                  </languageOfCataloging>
              </recordInfo></mods>').record_info
      @rlin = @mods_rec.from_str('<mods><recordInfo>
                 <descriptionStandard>appm</descriptionStandard>
                 <recordContentSource authority="marcorg">CSt</recordContentSource>
                 <recordCreationDate encoding="marc">850416</recordCreationDate>
                 <recordChangeDate encoding="iso8601">19991012150824.0</recordChangeDate>
                 <recordIdentifier source="CStRLIN">a4083219</recordIdentifier>
              </recordInfo></mods>').record_info
    end
    
    it "should be a NodeSet" do
      [@rec_info, @rec_info2, @bnf, @rlin].each { |ri| ri.should be_an_instance_of(Nokogiri::XML::NodeSet) }
    end
    it "should have as many members as there are <recordInfo> elements in the xml" do
      [@rec_info, @rec_info2, @bnf, @rlin].each { |ri| ri.size.should == 1 }
    end
    it "should recognize language attributes on <recordInfo> element" do
      pending "problem with xml:lang"
      Mods::LANG_ATTRIBS.each { |a| 
        @mods_rec.from_str("<mods><recordInfo #{a}='val'><recordOrigin>nowhere</recordOrigin></recordInfo></mods>")
        @mods_rec.record_info.send(a.to_sym).should == ['val']
      }
    end
    it "should recognize displayLabel attribute on <recordInfo> element" do
      @mods_rec.from_str("<mods><recordInfo displayLabel='val'><recordOrigin>nowhere</recordOrigin></recordInfo></mods>")
      @mods_rec.record_info.displayLabel.should == ['val']
    end

    context "<recordContentSource> child element" do
      it "should be a NodeSet" do
        [@rec_info, @rec_info2, @bnf, @rlin].each { |ri| ri.recordContentSource.should be_an_instance_of(Nokogiri::XML::NodeSet) }
      end
      it "recordContentSource NodeSet should have as many Nodes as there are <recordContentSource> elements in the xml" do
        [@rec_info, @rec_info2, @bnf, @rlin].each { |ri| ri.recordContentSource.size.should == 1 }
      end
      it "text should get element value" do
        @rec_info.recordContentSource.map { |n| n.text }.should == ["RQE"]
        @rec_info2.recordContentSource.map { |n| n.text }.should == ["AU@"]
        @bnf.recordContentSource.map { |n| n.text }.should == ["TEI Description"]
        @rlin.recordContentSource.map { |n| n.text }.should == ["CSt"]
      end
      it "should recognize authority attribute" do
        [@rec_info, @rec_info2, @rlin].each { |ri| ri.recordContentSource.authority.should == ['marcorg'] }
        @bnf.recordContentSource.authority.size.should == 0
      end
      it "should recognize all authority attributes" do
        Mods::AUTHORITY_ATTRIBS.each { |a|  
          @mods_rec.from_str("<mods><recordInfo><recordContentSource #{a}='attr_val'>zzz</recordContentSource></recordInfo></mods>")
          @mods_rec.record_info.recordContentSource.send(a.to_sym).should == ['attr_val']
        }
      end
    end # <recordContentSource>

    context "<recordCreationDate> child element" do
      it "should be a NodeSet" do
        [@rec_info, @rec_info2, @bnf, @rlin].each { |ri| ri.recordCreationDate.should be_an_instance_of(Nokogiri::XML::NodeSet) }
      end
      it "recordCreationDate NodeSet should have as many Nodes as there are <recordCreationDate> elements in the xml" do
        [@rec_info, @rec_info2, @bnf, @rlin].each { |ri| ri.recordCreationDate.size.should == 1 }
      end
      it "text should get element value" do
        @rec_info.recordCreationDate.map { |n| n.text }.should == ['890517']
        @rec_info2.recordCreationDate.map { |n| n.text }.should == ['050921']
        @bnf.recordCreationDate.map { |n| n.text }.should == ['2011-12-07']
        @rlin.recordCreationDate.map { |n| n.text }.should == ['850416']
      end
      it "should recognize encoding attribute" do
        [@rec_info, @rec_info2, @rlin].each { |ri| ri.recordCreationDate.encoding.should == ['marc'] }
        @bnf.recordCreationDate.encoding.should == ['w3cdtf']
      end
      it "should recognize all date attributes" do
        Mods::DATE_ATTRIBS.each { |a|  
          @mods_rec.from_str("<mods><recordInfo><recordCreationDate #{a}='attr_val'>zzz</recordCreationDate></recordInfo></mods>")
          @mods_rec.record_info.recordCreationDate.send(a.to_sym).should == ['attr_val']
        }
      end
    end # <recordCreationDate>

    context "<recordChangeDate> child element" do
      it "should be a NodeSet" do
        [@rec_info, @rec_info2, @bnf, @rlin].each { |ri| ri.recordChangeDate.should be_an_instance_of(Nokogiri::XML::NodeSet) }
      end
      it "recordChangeDate NodeSet should have as many Nodes as there are <recordChangeDate> elements in the xml" do
        [@rec_info, @rec_info2, @bnf].each { |ri| ri.recordChangeDate.size.should == 0 }
        @rlin.recordChangeDate.size.should == 1
      end
      it "text should get element value" do
        @rlin.recordChangeDate.map { |n| n.text }.should == ['19991012150824.0']
      end
      it "should recognize encoding attribute" do
        @rlin.recordChangeDate.encoding.should == ['iso8601']
      end
      it "should recognize all date attributes" do
        Mods::DATE_ATTRIBS.each { |a|  
          @mods_rec.from_str("<mods><recordInfo><recordChangeDate #{a}='attr_val'>zzz</recordChangeDate></recordInfo></mods>")
          @mods_rec.record_info.recordChangeDate.send(a.to_sym).should == ['attr_val']
        }
      end
    end # <recordChangeDate>

    context "<recordIdentifier> child element" do
      it "should be a NodeSet" do
        [@rec_info, @rec_info2, @bnf, @rlin].each { |ri| ri.recordIdentifier.should be_an_instance_of(Nokogiri::XML::NodeSet) }
      end
      it "recordIdentifier NodeSet should have as many Nodes as there are <recordIdentifier> elements in the xml" do
        [@rec_info, @rec_info2, @bnf, @rlin].each { |ri| ri.recordIdentifier.size.should == 1 }
      end
      it "text should get element value" do
        @rec_info.recordIdentifier.map { |n| n.text }.should == ['a9079953']
        @rec_info2.recordIdentifier.map { |n| n.text }.should == ['a8837534']
        @bnf.recordIdentifier.map { |n| n.text }.should == ['']
        @rlin.recordIdentifier.map { |n| n.text }.should == ['a4083219']
      end
      it "should recognize source attribute" do
        [@rec_info, @rec_info2].each { |ri| ri.recordIdentifier.source.should == ['SIRSI'] }
        @bnf.recordIdentifier.source.should == ['BNF 2166']
        @rlin.recordIdentifier.source.should == ['CStRLIN']
      end
      it "should allow a source attribute without element content" do
        @bnf.recordIdentifier.source.should == ['BNF 2166']
        @bnf.recordIdentifier.map { |n| n.text }.should == ['']
      end
    end # <recordIdentifier>

    context "<recordOrigin> child element" do
      it "should be a NodeSet" do
        [@rec_info, @rec_info2, @bnf, @rlin].each { |ri| ri.recordOrigin.should be_an_instance_of(Nokogiri::XML::NodeSet) }
      end
      it "recordOrigin NodeSet should have as many Nodes as there are <recordOrigin> elements in the xml" do
        [@rec_info, @rec_info2, @rlin].each { |ri| ri.recordOrigin.size.should == 0 }
        @bnf.recordOrigin.size.should == 1
      end
      it "text should get element value" do
        @mods_rec.from_str("<mods><recordInfo><recordOrigin>human prepared</recordOrigin></recordInfo></mods>")
        @mods_rec.record_info.recordOrigin.map {|n| n.text }.should == ['human prepared']
        @bnf.recordOrigin.map { |n| n.text }.should == ['']
      end
    end # <recordOrigin>

    context "<languageOfCataloging> child element" do
      it "should be a NodeSet" do
        [@rec_info, @rec_info2, @bnf, @rlin].each { |ri| ri.languageOfCataloging.should be_an_instance_of(Nokogiri::XML::NodeSet) }
      end
      it "languageOfCataloging NodeSet should have as many Nodes as there are <languageOfCataloging> elements in the xml" do
        [@rec_info2, @bnf].each { |ri| ri.languageOfCataloging.size.should == 1 }
        [@rec_info, @rlin].each { |ri| ri.languageOfCataloging.size.should == 0 }
      end
      it "text should get element value" do
        # this example is from   http://www.loc.gov/standards/mods/v3/mods-userguide-elements.html
        #   though it doesn't match the doc at http://www.loc.gov/standards/mods/mods-outline.html#recordInfo
        @mods_rec.from_str("<mods><recordInfo><languageOfCataloging authority='iso639-2b'>fre</languageOfCataloging></recordInfo></mods>")
        @mods_rec.record_info.languageOfCataloging.map { |n| n.text }.should == ['fre']
      end
      it "authority should get attribute value" do
        # this example is from   http://www.loc.gov/standards/mods/v3/mods-userguide-elements.html
        #   though it doesn't match the doc at http://www.loc.gov/standards/mods/mods-outline.html#recordInfo
        @mods_rec.from_str("<mods><recordInfo><languageOfCataloging authority='iso639-2b'>fre</languageOfCataloging></recordInfo></mods>")
        @mods_rec.record_info.languageOfCataloging.authority.should == ['iso639-2b']
      end
      
      # from http://www.loc.gov/standards/mods/userguide/recordinfo.html#languageofcataloging
      # objectPart attribute defined for consistency with <language> . Unlikely to be used with <languageOfCataloging> 
      it "objectType should get attribute value" do
        pending "<languageOfCataloging objectType=''> to be implemented ... maybe ..."
      end
      
      context "<languageTerm> child element" do
        it "text should get element value" do
          @rec_info2.languageOfCataloging.languageTerm.map { |n| n.text }.should == ['eng']
          @bnf.languageOfCataloging.languageTerm.map { |n| n.text }.should == ['fra']
        end
        it "should recognize all authority attributes" do
          Mods::AUTHORITY_ATTRIBS.each { |a|
            @mods_rec.from_str("<mods><recordInfo><languageOfCataloging><languageTerm #{a}='attr_val'>zzz</languageTerm></languageOfCataloging></recordInfo></mods>")
            @mods_rec.record_info.languageOfCataloging.languageTerm.send(a.to_sym).should == ['attr_val']
          }
        end
        it "should recognize the type attribute with type_at term" do
          @rec_info2.languageOfCataloging.languageTerm.type_at.should == ['code']
        end
      end # <languageTerm>
      
      context "<scriptTerm> child element" do
        it "should do something" do
          pending "<recordInfo><languageOfCataloging><scriptTerm> to be implemented"
        end
      end
    end # <languageOfCataloging>

    context "<descriptionStandard> child element" do
      it "should be a NodeSet" do
        [@rec_info, @rec_info2, @bnf, @rlin].each { |ri| ri.descriptionStandard.should be_an_instance_of(Nokogiri::XML::NodeSet) }
      end
      it "descriptionStandard NodeSet should have as many Nodes as there are <descriptionStandard> elements in the xml" do
        [@rec_info, @bnf].each { |ri| ri.descriptionStandard.size.should == 0 }
        [@rec_info2, @rlin].each { |ri| ri.descriptionStandard.size.should == 1 }
      end
      it "text should get element value" do
        @rec_info2.descriptionStandard.map { |n| n.text }.should == ['aacr2']
        @rlin.descriptionStandard.map { |n| n.text }.should == ['appm']
        @bnf.descriptionStandard.map { |n| n.text }.should == []
      end
      it "should recognize all authority attributes" do
        Mods::AUTHORITY_ATTRIBS.each { |a|  
          @mods_rec.from_str("<mods><recordInfo><descriptionStandard #{a}='attr_val'>zzz</descriptionStandard></recordInfo></mods>")
          @mods_rec.record_info.descriptionStandard.send(a.to_sym).should == ['attr_val']
        }
      end
    end # <descriptionStandard>

  end # basic <record_info> terminology pieces
end