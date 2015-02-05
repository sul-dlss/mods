require 'spec_helper'

describe "Mods <language> Element" do
  before(:all) do
    @mods_rec = Mods::Record.new
  end

  context "basic <language> terminology pieces" do
    
    context "namespace aware" do
      before(:all) do
        @ns_decl = "xmlns='#{Mods::MODS_NS}'"
        @iso639_2b_code = "<mods #{@ns_decl}><language><languageTerm authority='iso639-2b' type='code'>fre</languageTerm></language></mods>"
        @iso639_2b_code_ln = @mods_rec.from_str(@iso639_2b_code).language
        mult_code_terms = "<mods #{@ns_decl}><language><languageTerm authority='iso639-2b' type='code'>spa</languageTerm><languageTerm authority='iso639-2b' type='code'>dut</languageTerm></language></mods>"
        @mult_code_terms = @mods_rec.from_str(mult_code_terms).language
        mult_text_terms = "<mods #{@ns_decl}><language><languageTerm authority='iso639-2b' type='text'>Chinese</languageTerm><languageTerm authority='iso639-2b' type='text'>Spanish</languageTerm></language></mods>"
        @mult_text_terms = @mods_rec.from_str(mult_text_terms).language
        @ex_array = [@iso639_2b_code_ln, @mult_code_terms, @mult_text_terms]
      end
      it "should be a NodeSet" do
        @ex_array.each { |t| expect(t).to be_an_instance_of(Nokogiri::XML::NodeSet) }
      end
      it "should have as many members as there are <language> elements in the xml" do
        @ex_array.each { |t| expect(t.size).to eq(1) }
      end

      context "<languageTerm> child element" do
        it "should understand languageTerm.type_at attribute" do
          expect(@iso639_2b_code_ln.languageTerm.type_at).to eq(["code"])
        end
        it "should understand languageTerm.authority attribute" do
          expect(@iso639_2b_code_ln.languageTerm.authority).to eq(["iso639-2b"])
        end
        it "should understand languageTerm value" do
          expect(@iso639_2b_code_ln.languageTerm.text).to eq("fre")
          expect(@iso639_2b_code_ln.languageTerm.size).to eq(1)
        end

        it "should recognize all authority attributes" do
          Mods::AUTHORITY_ATTRIBS.each { |a|
            @mods_rec.from_str("<mods #{@ns_decl}><language><languageTerm #{a}='attr_val'>zzz</languageTerm></language></mods>")
            expect(@mods_rec.language.languageTerm.send(a.to_sym)).to eq(['attr_val'])
          }
        end
      end # <languageTerm> 

      it "should get one language.code_term for each languageTerm element with a type attribute of 'code'" do
        expect(@iso639_2b_code_ln.code_term.size).to eq(1)
        expect(@iso639_2b_code_ln.code_term.text).to eq("fre")
        expect(@mult_code_terms.code_term.size).to eq(2)
        expect(@mult_code_terms.code_term.first.text).to include("spa")
        expect(@mult_code_terms.code_term[1].text).to eq("dut")
      end
      it "should get one language.text_term for each languageTerm element with a type attribute of 'text'" do
        expect(@mult_text_terms.text_term.size).to eq(2)
        expect(@mult_text_terms.text_term.first.text).to include("Chinese")
        expect(@mult_text_terms.text_term[1].text).to eq("Spanish")
      end
    end # namespace_aware
    
    
    context "NOT namespace aware" do
      before(:all) do
        @iso639_2b_code = "<mods><language><languageTerm authority='iso639-2b' type='code'>fre</languageTerm></language></mods>"
        @iso639_2b_code_ln = @mods_rec.from_str(@iso639_2b_code, false).language
        mult_code_terms = "<mods><language><languageTerm authority='iso639-2b' type='code'>spa</languageTerm><languageTerm authority='iso639-2b' type='code'>dut</languageTerm></language></mods>"
        @mult_code_terms = @mods_rec.from_str(mult_code_terms, false).language
        mult_text_terms = "<mods><language><languageTerm authority='iso639-2b' type='text'>Chinese</languageTerm><languageTerm authority='iso639-2b' type='text'>Spanish</languageTerm></language></mods>"
        @mult_text_terms = @mods_rec.from_str(mult_text_terms, false).language
        @ex_array = [@iso639_2b_code_ln, @mult_code_terms, @mult_text_terms]
      end
      it "should be a NodeSet" do
        @ex_array.each { |t| expect(t).to be_an_instance_of(Nokogiri::XML::NodeSet) }
      end
      it "should have as many members as there are <language> elements in the xml" do
        @ex_array.each { |t| expect(t.size).to eq(1) }
      end

      context "<languageTerm> child element" do
        it "should understand languageTerm.type_at attribute" do
          expect(@iso639_2b_code_ln.languageTerm.type_at).to eq(["code"])
        end
        it "should understand languageTerm.authority attribute" do
          expect(@iso639_2b_code_ln.languageTerm.authority).to eq(["iso639-2b"])
        end
        it "should understand languageTerm value" do
          expect(@iso639_2b_code_ln.languageTerm.text).to eq("fre")
          expect(@iso639_2b_code_ln.languageTerm.size).to eq(1)
        end

        it "should recognize all authority attributes" do
          Mods::AUTHORITY_ATTRIBS.each { |a|
            @mods_rec.from_str("<mods><language><languageTerm #{a}='attr_val'>zzz</languageTerm></language></mods>", false)
            expect(@mods_rec.language.languageTerm.send(a.to_sym)).to eq(['attr_val'])
          }
        end
      end # <languageTerm> 

      it "should get one language.code_term for each languageTerm element with a type attribute of 'code'" do
        expect(@iso639_2b_code_ln.code_term.size).to eq(1)
        expect(@iso639_2b_code_ln.code_term.text).to eq("fre")
        expect(@mult_code_terms.code_term.size).to eq(2)
        expect(@mult_code_terms.code_term.first.text).to include("spa")
        expect(@mult_code_terms.code_term[1].text).to eq("dut")
      end
      it "should get one language.text_term for each languageTerm element with a type attribute of 'text'" do
        expect(@mult_text_terms.text_term.size).to eq(2)
        expect(@mult_text_terms.text_term.first.text).to include("Chinese")
        expect(@mult_text_terms.text_term[1].text).to eq("Spanish")
      end
    end # NOT namespace_aware

  end # basic <language> terminology pieces
  
  # note that Mods::Record.languages tests are in record_spec
  
end