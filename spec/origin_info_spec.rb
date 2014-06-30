# encoding: utf-8
require 'spec_helper'

describe "Mods <originInfo> Element" do
  before(:all) do
    @mods_rec = Mods::Record.new
    @ns_decl = "xmlns='#{Mods::MODS_NS}'"
    @kolb = "<mods>
    <originInfo>
            <dateCreated>1537-1553.</dateCreated>
            <dateCreated point='start'>1537</dateCreated>
            <dateCreated point='end'>1553</dateCreated>
        </originInfo></mods>"
    @reid_dennis = "<mods><originInfo><dateIssued>1852</dateIssued></originInfo></mods>"
    @walters = "<mods><originInfo>
       <place>
          <placeTerm type='text'>Iran</placeTerm>
       </place>
       <dateIssued>22 Rabīʿ II 889 AH / 1484 CE</dateIssued>
       <issuance>monographic</issuance>
    </originInfo>
    </mods>"
    @simple = "<mods><originInfo><dateIssued>circa 1900</dateIssued></originInfo></mods>"
    @ew = "<mods><originInfo>
      <place>
        <placeTerm type='text'>Reichenau Abbey, Lake Constance, Germany</placeTerm>
      </place>
      <dateIssued>Middle of the 11th century CE</dateIssued>
      <issuance>monographic</issuance>
    </originInfo>
    </mods>"
    @e = "<mods><originInfo>
              <place>
                 <placeTerm type='code' authority='marccountry'>au</placeTerm>
              </place>
              <place>
                 <placeTerm type='text'>[Austria?</placeTerm>
              </place>
              <dateIssued>circa 1180-1199]</dateIssued>
              <issuance>monographic</issuance>
           </originInfo></mods>"
    @f = "<mods>       <originInfo>
             <place>
               <placeTerm authority='marccountry' type='code'>cau</placeTerm>
             </place>
             <dateIssued encoding='marc' keyDate='yes' point='start'>1850</dateIssued>
             <dateIssued encoding='marc' point='end'>1906</dateIssued>
             <issuance>monographic</issuance>
           </originInfo>
    </mods>"
    @ex = "<mods><originInfo>
      <place>
        <placeTerm>France and Italy</placeTerm>
      </place>
      <dateCreated keyDate='yes' qualifier='inferred'>173-?</dateCreated>
    </originInfo>
    </mods>"
    @ex1 = "<mods><originInfo>
  	<publisher>Robot Publishing</publisher>
      <place>
        <placeTerm>France</placeTerm>
      </place>
      <place>
        <placeTerm>Italy</placeTerm>
      </place>
      <dateCreated keyDate='yes' qualifier='inferred'>173-?</dateCreated>
  	<dateIssued>1850</dateIssued>
    </originInfo>
    </mods>"
    @ex2 = "<mods><originInfo>
        <place>
           <placeTerm type='code' authority='marccountry'>enk</placeTerm>
        </place>
        <place>
           <placeTerm type='text'>[London]</placeTerm>
        </place>
        <publisher>Bunney &amp; Gold</publisher>
        <dateIssued>1799</dateIssued>
        <dateIssued encoding='marc' keyDate='yes'>1799</dateIssued>
        <issuance>monographic</issuance>
     </originInfo>
    </mods>"
    @ex3 = "<mods><originInfo>
       <place>
          <placeTerm type='code' authority='marccountry'>xx</placeTerm>
       </place>
       <place>
          <placeTerm type='text'>[s.l. : s.n.]</placeTerm>
       </place>
       <dateIssued>1780?]</dateIssued>
       <dateIssued encoding='marc' keyDate='yes'>178u</dateIssued>
       <issuance>monographic</issuance>
    </originInfo>
    </mods>"
    @ex4 = "<mods><originInfo>
       <place>
          <placeTerm type='code' authority='marccountry'>fr</placeTerm>
       </place>
       <place>
          <placeTerm type='text'>[S.l.]</placeTerm>
       </place>
       <publisher>[s.n.]</publisher>
       <dateIssued>[1740.]</dateIssued>
       <dateIssued encoding='marc' point='start' qualifier='questionable' keyDate='yes'>1740</dateIssued>
       <dateIssued encoding='marc' point='end' qualifier='questionable'>1749</dateIssued>
       <issuance>monographic</issuance>
    </originInfo>
    </mods>"
    @ex5 = "<mods><originInfo>
        <place>
           <placeTerm type='code' authority='marccountry'>xx</placeTerm>
        </place>
        <place>
           <placeTerm type='text'>[S.l.]</placeTerm>
        </place>
        <publisher>Olney</publisher>
        <dateIssued>1844</dateIssued>
        <dateIssued encoding='marc' keyDate='yes'>1844</dateIssued>
        <issuance>monographic</issuance>
     </originInfo>
    </mods>"
    @ex6 = "<mods><originInfo>
       <place>
          <placeTerm type='code' authority='marccountry'>enk</placeTerm>
       </place>
       <place>
          <placeTerm type='text'>[London</placeTerm>
       </place>
       <publisher>Printed for William Innys and Joseph Richardson ... [et al.]</publisher>
       <dateIssued>1752]</dateIssued>
       <dateIssued encoding='marc' keyDate='yes'>1752</dateIssued>
       <issuance>monographic</issuance>
    </originInfo>
    </mods>"
    @ex7 = "<mods><originInfo>
       <place>
          <placeTerm authority='marccountry' type='code'>fr</placeTerm>
       </place>
       <place>
          <placeTerm type='text'>[S.l.]</placeTerm>
       </place>
       <publisher>[s.n.]</publisher>
       <dateIssued>[1740.]</dateIssued>
       <dateIssued encoding='marc' keyDate='yes' point='start' qualifier='questionable'>1740</dateIssued>
       <dateIssued encoding='marc' point='end' qualifier='questionable'>1749</dateIssued>
       <issuance>monographic</issuance>
    </originInfo>
    </mods>"

    xml = "<originInfo>
    <dateCreated encoding='w3cdtf' keyDate='yes' point='start' qualifier='approximate'>250 B.C.</dateCreated>
    <dateCreated encoding='w3cdtf' keyDate='yes' point='end' qualifier='approximate'>150 B.C.</dateCreated>
    </originInfo>"

  end

  context "parsing date values" do
    it "should cope with slop" do
      skip "to be implemented"
    end
    it "should know something about various date encodings: w3cdtf, iso8601, marc, edtf, temper" do
      skip "to be implemented"
    end
    it "should know the only valid values for point attribute are 'start' and 'end'" do
      skip "to be implemented"
    end
    it "should know the only valid value for keyDate attribute is 'yes" do
      skip "to be implemented"
    end
    it "should know the only valid values for qualifier attribute: approximate, inferred, questionable" do
      skip "to be implemented"
    end
  end

  context "parsing issuance" do
    it "should know the only valid values are: continuing, monographic, single unit, multipart monograph, serial, integrating resource" do
      skip "to be implemented"
    end
  end

  context "parsing publisher" do
    it "should ignore s.n. value (from MARC)" do
      skip "to be implemented"
    end
    it "should leave square brackets alone, except for s.n." do
      skip "to be implemented"
    end
  end

  context "parsing placeTerm" do
    it "should be able to translate marccountry codes" do
      skip "to be implemented"
    end
    it "should ignore s.l. value (from MARC)" do
      skip "to be implemented"
    end
    it "should be forgiving of square brackets (from MARC), matched or unmatched" do
      skip "to be implemented"
    end
  end


  context "basic <originInfo> terminology pieces" do

    context "WITH namespaces" do
      context "<place> child element" do
        before(:all) do
          @place_term_text = "<mods #{@ns_decl}><originInfo><place><placeTerm type='text'>Iran</placeTerm></place></originInfo></mods>"
          @place_term_plain_mult = "<mods #{@ns_decl}><originInfo>
                        <place><placeTerm>France</placeTerm></place>
                        <place><placeTerm>Italy</placeTerm></place></originInfo></mods>"
          @place_term_code = "<mods #{@ns_decl}><originInfo><place><placeTerm authority='marccountry' type='code'>fr</placeTerm></place></originInfo></mods>"
          @yuck1 = "<mods #{@ns_decl}><originInfo><place><placeTerm type='text'>[S.l.]</placeTerm></place></originInfo></mods>"
          @yuck2 = "<mods #{@ns_decl}><originInfo><place><placeTerm type='text'>[London</placeTerm></place></originInfo></mods>"
          @yuck3 = "<mods #{@ns_decl}><originInfo><place><placeTerm type='text'>[s.l. : s.n.]</placeTerm></place></originInfo></mods>"
          @yuck4 = "<mods #{@ns_decl}><originInfo><place><placeTerm type='text'>[London]</placeTerm></place></originInfo></mods>"
        end
        context "<placeTerm> child element" do
          it "should get element values" do
            vals = @mods_rec.from_str(@place_term_plain_mult).origin_info.place.placeTerm.map { |e| e.text}
            vals.size.should == 2
            vals.should include("France")
            vals.should include("Italy")
          end
          it "should get authority attribute" do
            @mods_rec.from_str(@place_term_code).origin_info.place.placeTerm.authority.should == ["marccountry"]
          end
          it "should get type(_at) attribute" do
            @mods_rec.from_str(@place_term_code).origin_info.place.placeTerm.type_at.should == ["code"]
          end
        end # placeTerm
      end # place

      context "<publisher> child element" do
        before(:all) do
          @ex = "<mods #{@ns_decl}><originInfo><publisher>Olney</publisher></origin_info></mods>"
          @yuck1 = "<mods #{@ns_decl}><originInfo><publisher>[s.n.]</publisher></originInfo></mods>"
          @yuck2 = "<mods #{@ns_decl}><originInfo><publisher>Printed for William Innys and Joseph Richardson ... [et al.]</publisher></originInfo></mods>"
        end
        it "should get element values" do
          vals = @mods_rec.from_str("<mods #{@ns_decl}><originInfo><publisher>Olney</publisher></origin_info></mods>").origin_info.publisher
          vals.map { |n| n.text }.should == ["Olney"]
        end
      end

      context "<xxxDate> child elements" do
        it "should recognize each element" do
          Mods::ORIGIN_INFO_DATE_ELEMENTS.each { |elname|
            @mods_rec.from_str("<mods #{@ns_decl}><originInfo><#{elname}>date</#{elname}></originInfo></mods>")
            @mods_rec.origin_info.send(elname.to_sym).map { |n| n.text }.should == ["date"]
          }
        end
        it "should recognize encoding attribute on each element" do
          Mods::ORIGIN_INFO_DATE_ELEMENTS.each { |elname|
            @mods_rec.from_str("<mods #{@ns_decl}><originInfo><#{elname} encoding='foo'>date</#{elname}></originInfo></mods>")
            @mods_rec.origin_info.send(elname.to_sym).encoding.should == ["foo"]
          }
        end
        it "should recognize keyDate attribute" do
          Mods::ORIGIN_INFO_DATE_ELEMENTS.each { |elname|
            @mods_rec.from_str("<mods #{@ns_decl}><originInfo><#{elname} keyDate='foo'>date</#{elname}></originInfo></mods>")
            @mods_rec.origin_info.send(elname.to_sym).keyDate.should == ["foo"]
          }
        end
        it "should recognize point attribute" do
          # NOTE: values allowed are 'start' and 'end'
          Mods::ORIGIN_INFO_DATE_ELEMENTS.each { |elname|
            @mods_rec.from_str("<mods #{@ns_decl}><originInfo><#{elname} point='foo'>date</#{elname}></originInfo></mods>")
            @mods_rec.origin_info.send(elname.to_sym).point.should == ["foo"]
          }
        end
        it "should recognize qualifier attribute" do
          Mods::ORIGIN_INFO_DATE_ELEMENTS.each { |elname|
            @mods_rec.from_str("<mods #{@ns_decl}><originInfo><#{elname} qualifier='foo'>date</#{elname}></originInfo></mods>")
            @mods_rec.origin_info.send(elname.to_sym).qualifier.should == ["foo"]
          }
        end
        it "should recognize type attribute only on dateOther" do
          Mods::ORIGIN_INFO_DATE_ELEMENTS.each { |elname|
            @mods_rec.from_str("<mods #{@ns_decl}><originInfo><#{elname} type='foo'>date</#{elname}></originInfo></mods>")
            if elname == 'dateOther'
              @mods_rec.origin_info.send(elname.to_sym).type_at.should == ["foo"]
            else
              expect { @mods_rec.origin_info.send(elname.to_sym).type_at}.to raise_exception(NoMethodError, /type_at/)
            end
          }
        end
      end # <xxxDate> child elements

      it "<edition> child element" do
        xml = "<mods #{@ns_decl}><originInfo><edition>7th ed.</edition></originInfo></mods>"
        @mods_rec.from_str(xml).origin_info.edition.map { |n| n.text }.should == ['7th ed.']
      end

      context "<issuance> child element" do
        before(:all) do
          @ex = "<mods #{@ns_decl}><originInfo><issuance>monographic</issuance></originInfo></mods>"
        end
        it "should get element value" do
          @mods_rec.from_str(@ex).origin_info.issuance.map { |n| n.text }.should == ['monographic']
        end
      end

      context "<frequency> child element" do
        before(:all) do
          xml = "<mods #{@ns_decl}><originInfo><frequency authority='marcfrequency'>Annual</frequency></originInfo></mods>"
          @origin_info = @mods_rec.from_str(xml).origin_info
        end
        it "should get element value" do
          @origin_info.frequency.map { |n| n.text }.should == ["Annual"]
        end
        it "should recognize the authority attribute" do
          @origin_info.frequency.authority.should == ["marcfrequency"]
        end
      end
    end # WITH namspaces

    context "WITHOUT namespaces" do
      context "<place> child element" do
        before(:all) do
          @place_term_text = "<mods><originInfo><place><placeTerm type='text'>Iran</placeTerm></place></originInfo></mods>"
          @place_term_plain_mult = "<mods><originInfo>
                        <place><placeTerm>France</placeTerm></place>
                        <place><placeTerm>Italy</placeTerm></place></originInfo></mods>"
          @place_term_code = "<mods><originInfo><place><placeTerm authority='marccountry' type='code'>fr</placeTerm></place></originInfo></mods>"
          @yuck1 = "<mods><originInfo><place><placeTerm type='text'>[S.l.]</placeTerm></place></originInfo></mods>"
          @yuck2 = "<mods><originInfo><place><placeTerm type='text'>[London</placeTerm></place></originInfo></mods>"
          @yuck3 = "<mods><originInfo><place><placeTerm type='text'>[s.l. : s.n.]</placeTerm></place></originInfo></mods>"
          @yuck4 = "<mods><originInfo><place><placeTerm type='text'>[London]</placeTerm></place></originInfo></mods>"
        end
        context "<placeTerm> child element" do
          it "should get element values" do
            vals = @mods_rec.from_str(@place_term_plain_mult, false).origin_info.place.placeTerm.map { |e| e.text}
            vals.size.should == 2
            vals.should include("France")
            vals.should include("Italy")
          end
          it "should get authority attribute" do
            @mods_rec.from_str(@place_term_code, false).origin_info.place.placeTerm.authority.should == ["marccountry"]
          end
          it "should get type(_at) attribute" do
            @mods_rec.from_str(@place_term_code, false).origin_info.place.placeTerm.type_at.should == ["code"]
          end
        end # placeTerm
      end # place

      context "<publisher> child element" do
        before(:all) do
          @ex = "<mods><originInfo><publisher>Olney</publisher></origin_info></mods>"
          @yuck1 = "<mods><originInfo><publisher>[s.n.]</publisher></originInfo></mods>"
          @yuck2 = "<mods><originInfo><publisher>Printed for William Innys and Joseph Richardson ... [et al.]</publisher></originInfo></mods>"
        end
        it "should get element values" do
          vals = @mods_rec.from_str("<mods><originInfo><publisher>Olney</publisher></origin_info></mods>", false).origin_info.publisher
          vals.map { |n| n.text }.should == ["Olney"]
        end
      end

      context "<xxxDate> child elements" do
        it "should recognize each element" do
          Mods::ORIGIN_INFO_DATE_ELEMENTS.each { |elname|
            @mods_rec.from_str("<mods><originInfo><#{elname}>date</#{elname}></originInfo></mods>", false)
            @mods_rec.origin_info.send(elname.to_sym).map { |n| n.text }.should == ["date"]
          }
        end
        it "should recognize encoding attribute on each element" do
          Mods::ORIGIN_INFO_DATE_ELEMENTS.each { |elname|
            @mods_rec.from_str("<mods><originInfo><#{elname} encoding='foo'>date</#{elname}></originInfo></mods>", false)
            @mods_rec.origin_info.send(elname.to_sym).encoding.should == ["foo"]
          }
        end
        it "should recognize keyDate attribute" do
          Mods::ORIGIN_INFO_DATE_ELEMENTS.each { |elname|
            @mods_rec.from_str("<mods><originInfo><#{elname} keyDate='foo'>date</#{elname}></originInfo></mods>", false)
            @mods_rec.origin_info.send(elname.to_sym).keyDate.should == ["foo"]
          }
        end
        it "should recognize point attribute" do
          # NOTE: values allowed are 'start' and 'end'
          Mods::ORIGIN_INFO_DATE_ELEMENTS.each { |elname|
            @mods_rec.from_str("<mods><originInfo><#{elname} point='foo'>date</#{elname}></originInfo></mods>", false)
            @mods_rec.origin_info.send(elname.to_sym).point.should == ["foo"]
          }
        end
        it "should recognize qualifier attribute" do
          Mods::ORIGIN_INFO_DATE_ELEMENTS.each { |elname|
            @mods_rec.from_str("<mods><originInfo><#{elname} qualifier='foo'>date</#{elname}></originInfo></mods>", false)
            @mods_rec.origin_info.send(elname.to_sym).qualifier.should == ["foo"]
          }
        end
        it "should recognize type attribute only on dateOther" do
          Mods::ORIGIN_INFO_DATE_ELEMENTS.each { |elname|
            @mods_rec.from_str("<mods><originInfo><#{elname} type='foo'>date</#{elname}></originInfo></mods>", false)
            if elname == 'dateOther'
              @mods_rec.origin_info.send(elname.to_sym).type_at.should == ["foo"]
            else
              expect { @mods_rec.origin_info.send(elname.to_sym).type_at}.to raise_exception(NoMethodError, /type_at/)
            end
          }
        end
      end # <xxxDate> child elements

      it "<edition> child element" do
        xml = "<mods><originInfo><edition>7th ed.</edition></originInfo></mods>"
        @mods_rec.from_str(xml, false).origin_info.edition.map { |n| n.text }.should == ['7th ed.']
      end

      context "<issuance> child element" do
        before(:all) do
          @ex = "<mods><originInfo><issuance>monographic</issuance></originInfo></mods>"
        end
        it "should get element value" do
          @mods_rec.from_str(@ex, false).origin_info.issuance.map { |n| n.text }.should == ['monographic']
        end
      end

      context "<frequency> child element" do
        before(:all) do
          xml = "<mods><originInfo><frequency authority='marcfrequency'>Annual</frequency></originInfo></mods>"
          @origin_info = @mods_rec.from_str(xml, false).origin_info
        end
        it "should get element value" do
          @origin_info.frequency.map { |n| n.text }.should == ["Annual"]
        end
        it "should recognize the authority attribute" do
          @origin_info.frequency.authority.should == ["marcfrequency"]
        end
      end
    end # WITHOUT namspaces

  end # basic terminology

end
