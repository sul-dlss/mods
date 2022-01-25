require 'spec_helper'

describe "Mods <recordInfo> Element" do
  before(:all) do
    @mods_rec = Mods::Record.new
    @ns_decl = "xmlns='#{Mods::MODS_NS}'"
  end

  it "should translate language codes" do
    skip "to be implemented"
  end

  it "should normalize dates" do
    skip "to be implemented"
  end

  context "basic <record_info> terminology pieces" do

    context "WITH namespaces" do
      before(:all) do
        @rec_info = @mods_rec.from_str("<mods #{@ns_decl}><recordInfo>
                  <recordContentSource authority='marcorg'>RQE</recordContentSource>
                  <recordCreationDate encoding='marc'>890517</recordCreationDate>
                  <recordIdentifier source='SIRSI'>a9079953</recordIdentifier>
               </recordInfo></mods>").record_info
        @rec_info2 = @mods_rec.from_str("<mods #{@ns_decl}><recordInfo>
                   <descriptionStandard>aacr2</descriptionStandard>
                   <recordContentSource authority='marcorg'>AU@</recordContentSource>
                   <recordCreationDate encoding='marc'>050921</recordCreationDate>
                   <recordIdentifier source='SIRSI'>a8837534</recordIdentifier>
                   <languageOfCataloging>
                      <languageTerm authority='iso639-2b' type='code'>eng</languageTerm>
                   </languageOfCataloging>
               </recordInfo></mods>").record_info
        @bnf = @mods_rec.from_str("<mods #{@ns_decl}><recordInfo>
                    <recordContentSource>TEI Description</recordContentSource>
                    <recordCreationDate encoding='w3cdtf'>2011-12-07</recordCreationDate>
                    <recordIdentifier source='BNF 2166'/>
                    <recordOrigin/>
                    <languageOfCataloging>
                        <languageTerm authority='iso639-2b'>fra</languageTerm>
                    </languageOfCataloging>
                </recordInfo></mods>").record_info
        @rlin = @mods_rec.from_str("<mods #{@ns_decl}><recordInfo>
                   <descriptionStandard>appm</descriptionStandard>
                   <recordContentSource authority='marcorg'>CSt</recordContentSource>
                   <recordCreationDate encoding='marc'>850416</recordCreationDate>
                   <recordChangeDate encoding='iso8601'>19991012150824.0</recordChangeDate>
                   <recordIdentifier source='CStRLIN'>a4083219</recordIdentifier>
                </recordInfo></mods>").record_info
      end

      it "should be a NodeSet" do
        [@rec_info, @rec_info2, @bnf, @rlin].each { |ri| expect(ri).to be_an_instance_of(Nokogiri::XML::NodeSet) }
      end
      it "should have as many members as there are <recordInfo> elements in the xml" do
        [@rec_info, @rec_info2, @bnf, @rlin].each { |ri| expect(ri.size).to eq(1) }
      end
      it "should recognize language attributes on <recordInfo> element" do
        skip "problem with xml:lang"
        Mods::LANG_ATTRIBS.each { |a|
          @mods_rec.from_str("<mods #{@ns_decl}><recordInfo #{a}='val'><recordOrigin>nowhere</recordOrigin></recordInfo></mods>")
          expect(@mods_rec.record_info.send(a.to_sym)).to eq(['val'])
        }
      end
      it "should recognize displayLabel attribute on <recordInfo> element" do
        @mods_rec.from_str("<mods #{@ns_decl}><recordInfo displayLabel='val'><recordOrigin>nowhere</recordOrigin></recordInfo></mods>")
        expect(@mods_rec.record_info.displayLabel).to eq(['val'])
      end

      context "<recordContentSource> child element" do
        it "should be a NodeSet" do
          [@rec_info, @rec_info2, @bnf, @rlin].each { |ri| expect(ri.recordContentSource).to be_an_instance_of(Nokogiri::XML::NodeSet) }
        end
        it "recordContentSource NodeSet should have as many Nodes as there are <recordContentSource> elements in the xml" do
          [@rec_info, @rec_info2, @bnf, @rlin].each { |ri| expect(ri.recordContentSource.size).to eq(1) }
        end
        it "text should get element value" do
          expect(@rec_info.recordContentSource.map { |n| n.text }).to eq(["RQE"])
          expect(@rec_info2.recordContentSource.map { |n| n.text }).to eq(["AU@"])
          expect(@bnf.recordContentSource.map { |n| n.text }).to eq(["TEI Description"])
          expect(@rlin.recordContentSource.map { |n| n.text }).to eq(["CSt"])
        end
        it "should recognize authority attribute" do
          [@rec_info, @rec_info2, @rlin].each { |ri| expect(ri.recordContentSource.authority).to eq(['marcorg']) }
          expect(@bnf.recordContentSource.authority.size).to eq(0)
        end
        it "should recognize all authority attributes" do
          Mods::AUTHORITY_ATTRIBS.each { |a|
            @mods_rec.from_str("<mods #{@ns_decl}><recordInfo><recordContentSource #{a}='attr_val'>zzz</recordContentSource></recordInfo></mods>")
            expect(@mods_rec.record_info.recordContentSource.send(a.to_sym)).to eq(['attr_val'])
          }
        end
      end # <recordContentSource>

      context "<recordCreationDate> child element" do
        it "should be a NodeSet" do
          [@rec_info, @rec_info2, @bnf, @rlin].each { |ri| expect(ri.recordCreationDate).to be_an_instance_of(Nokogiri::XML::NodeSet) }
        end
        it "recordCreationDate NodeSet should have as many Nodes as there are <recordCreationDate> elements in the xml" do
          [@rec_info, @rec_info2, @bnf, @rlin].each { |ri| expect(ri.recordCreationDate.size).to eq(1) }
        end
        it "text should get element value" do
          expect(@rec_info.recordCreationDate.map { |n| n.text }).to eq(['890517'])
          expect(@rec_info2.recordCreationDate.map { |n| n.text }).to eq(['050921'])
          expect(@bnf.recordCreationDate.map { |n| n.text }).to eq(['2011-12-07'])
          expect(@rlin.recordCreationDate.map { |n| n.text }).to eq(['850416'])
        end
        it "should recognize encoding attribute" do
          [@rec_info, @rec_info2, @rlin].each { |ri| expect(ri.recordCreationDate.encoding).to eq(['marc']) }
          expect(@bnf.recordCreationDate.encoding).to eq(['w3cdtf'])
        end
        it "should recognize all date attributes" do
          Mods::DATE_ATTRIBS.each { |a|
            @mods_rec.from_str("<mods #{@ns_decl}><recordInfo><recordCreationDate #{a}='attr_val'>zzz</recordCreationDate></recordInfo></mods>")
            expect(@mods_rec.record_info.recordCreationDate.send(a.to_sym)).to eq(['attr_val'])
          }
        end
      end # <recordCreationDate>

      context "<recordChangeDate> child element" do
        it "should be a NodeSet" do
          [@rec_info, @rec_info2, @bnf, @rlin].each { |ri| expect(ri.recordChangeDate).to be_an_instance_of(Nokogiri::XML::NodeSet) }
        end
        it "recordChangeDate NodeSet should have as many Nodes as there are <recordChangeDate> elements in the xml" do
          [@rec_info, @rec_info2, @bnf].each { |ri| expect(ri.recordChangeDate.size).to eq(0) }
          expect(@rlin.recordChangeDate.size).to eq(1)
        end
        it "text should get element value" do
          expect(@rlin.recordChangeDate.map { |n| n.text }).to eq(['19991012150824.0'])
        end
        it "should recognize encoding attribute" do
          expect(@rlin.recordChangeDate.encoding).to eq(['iso8601'])
        end
        it "should recognize all date attributes" do
          Mods::DATE_ATTRIBS.each { |a|
            @mods_rec.from_str("<mods #{@ns_decl}><recordInfo><recordChangeDate #{a}='attr_val'>zzz</recordChangeDate></recordInfo></mods>")
            expect(@mods_rec.record_info.recordChangeDate.send(a.to_sym)).to eq(['attr_val'])
          }
        end
      end # <recordChangeDate>

      context "<recordIdentifier> child element" do
        it "should be a NodeSet" do
          [@rec_info, @rec_info2, @bnf, @rlin].each { |ri| expect(ri.recordIdentifier).to be_an_instance_of(Nokogiri::XML::NodeSet) }
        end
        it "recordIdentifier NodeSet should have as many Nodes as there are <recordIdentifier> elements in the xml" do
          [@rec_info, @rec_info2, @bnf, @rlin].each { |ri| expect(ri.recordIdentifier.size).to eq(1) }
        end
        it "text should get element value" do
          expect(@rec_info.recordIdentifier.map { |n| n.text }).to eq(['a9079953'])
          expect(@rec_info2.recordIdentifier.map { |n| n.text }).to eq(['a8837534'])
          expect(@bnf.recordIdentifier.map { |n| n.text }).to eq([''])
          expect(@rlin.recordIdentifier.map { |n| n.text }).to eq(['a4083219'])
        end
        it "should recognize source attribute" do
          [@rec_info, @rec_info2].each { |ri| expect(ri.recordIdentifier.source).to eq(['SIRSI']) }
          expect(@bnf.recordIdentifier.source).to eq(['BNF 2166'])
          expect(@rlin.recordIdentifier.source).to eq(['CStRLIN'])
        end
        it "should allow a source attribute without element content" do
          expect(@bnf.recordIdentifier.source).to eq(['BNF 2166'])
          expect(@bnf.recordIdentifier.map { |n| n.text }).to eq([''])
        end
      end # <recordIdentifier>

      context "<recordOrigin> child element" do
        it "should be a NodeSet" do
          [@rec_info, @rec_info2, @bnf, @rlin].each { |ri| expect(ri.recordOrigin).to be_an_instance_of(Nokogiri::XML::NodeSet) }
        end
        it "recordOrigin NodeSet should have as many Nodes as there are <recordOrigin> elements in the xml" do
          [@rec_info, @rec_info2, @rlin].each { |ri| expect(ri.recordOrigin.size).to eq(0) }
          expect(@bnf.recordOrigin.size).to eq(1)
        end
        it "text should get element value" do
          @mods_rec.from_str("<mods #{@ns_decl}><recordInfo><recordOrigin>human prepared</recordOrigin></recordInfo></mods>")
          expect(@mods_rec.record_info.recordOrigin.map {|n| n.text }).to eq(['human prepared'])
          expect(@bnf.recordOrigin.map { |n| n.text }).to eq([''])
        end
      end # <recordOrigin>

      context "<languageOfCataloging> child element" do
        it "should be a NodeSet" do
          [@rec_info, @rec_info2, @bnf, @rlin].each { |ri| expect(ri.languageOfCataloging).to be_an_instance_of(Nokogiri::XML::NodeSet) }
        end
        it "languageOfCataloging NodeSet should have as many Nodes as there are <languageOfCataloging> elements in the xml" do
          [@rec_info2, @bnf].each { |ri| expect(ri.languageOfCataloging.size).to eq(1) }
          [@rec_info, @rlin].each { |ri| expect(ri.languageOfCataloging.size).to eq(0) }
        end
        it "text should get element value" do
          # this example is from   http://www.loc.gov/standards/mods/v3/mods-userguide-elements.html
          #   though it doesn't match the doc at http://www.loc.gov/standards/mods/mods-outline.html#recordInfo
          @mods_rec.from_str("<mods #{@ns_decl}><recordInfo><languageOfCataloging authority='iso639-2b'>fre</languageOfCataloging></recordInfo></mods>")
          expect(@mods_rec.record_info.languageOfCataloging.map { |n| n.text }).to eq(['fre'])
        end
        it "authority should get attribute value" do
          # this example is from   http://www.loc.gov/standards/mods/v3/mods-userguide-elements.html
          #   though it doesn't match the doc at http://www.loc.gov/standards/mods/mods-outline.html#recordInfo
          @mods_rec.from_str("<mods #{@ns_decl}><recordInfo><languageOfCataloging authority='iso639-2b'>fre</languageOfCataloging></recordInfo></mods>")
          expect(@mods_rec.record_info.languageOfCataloging.authority).to eq(['iso639-2b'])
        end

        # from http://www.loc.gov/standards/mods/userguide/recordinfo.html#languageofcataloging
        # objectPart attribute defined for consistency with <language> . Unlikely to be used with <languageOfCataloging>
        it "objectType should get attribute value" do
          skip "<languageOfCataloging objectType=''> to be implemented ... maybe ..."
        end

        context "<languageTerm> child element" do
          it "text should get element value" do
            expect(@rec_info2.languageOfCataloging.languageTerm.map { |n| n.text }).to eq(['eng'])
            expect(@bnf.languageOfCataloging.languageTerm.map { |n| n.text }).to eq(['fra'])
          end
          it "should recognize all authority attributes" do
            Mods::AUTHORITY_ATTRIBS.each { |a|
              @mods_rec.from_str("<mods #{@ns_decl}><recordInfo><languageOfCataloging><languageTerm #{a}='attr_val'>zzz</languageTerm></languageOfCataloging></recordInfo></mods>")
              expect(@mods_rec.record_info.languageOfCataloging.languageTerm.send(a.to_sym)).to eq(['attr_val'])
            }
          end
          it "should recognize the type attribute with type_at term" do
            expect(@rec_info2.languageOfCataloging.languageTerm.type_at).to eq(['code'])
          end
        end # <languageTerm>

        context "<scriptTerm> child element" do
          it "should do something" do
            skip "<recordInfo><languageOfCataloging><scriptTerm> to be implemented"
          end
        end
      end # <languageOfCataloging>

      context "<descriptionStandard> child element" do
        it "should be a NodeSet" do
          [@rec_info, @rec_info2, @bnf, @rlin].each { |ri| expect(ri.descriptionStandard).to be_an_instance_of(Nokogiri::XML::NodeSet) }
        end
        it "descriptionStandard NodeSet should have as many Nodes as there are <descriptionStandard> elements in the xml" do
          [@rec_info, @bnf].each { |ri| expect(ri.descriptionStandard.size).to eq(0) }
          [@rec_info2, @rlin].each { |ri| expect(ri.descriptionStandard.size).to eq(1) }
        end
        it "text should get element value" do
          expect(@rec_info2.descriptionStandard.map { |n| n.text }).to eq(['aacr2'])
          expect(@rlin.descriptionStandard.map { |n| n.text }).to eq(['appm'])
          expect(@bnf.descriptionStandard.map { |n| n.text }).to eq([])
        end
        it "should recognize all authority attributes" do
          Mods::AUTHORITY_ATTRIBS.each { |a|
            @mods_rec.from_str("<mods #{@ns_decl}><recordInfo><descriptionStandard #{a}='attr_val'>zzz</descriptionStandard></recordInfo></mods>")
            expect(@mods_rec.record_info.descriptionStandard.send(a.to_sym)).to eq(['attr_val'])
          }
        end
      end # <descriptionStandard>

    end # WITH namespaces
  end # basic <record_info> terminology pieces

end
