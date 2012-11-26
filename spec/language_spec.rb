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
        @ex_array.each { |t| t.should be_an_instance_of(Nokogiri::XML::NodeSet) }
      end
      it "should have as many members as there are <language> elements in the xml" do
        @ex_array.each { |t| t.size.should == 1 }
      end

      context "<languageTerm> child element" do
        it "should understand languageTerm.type_at attribute" do
          @iso639_2b_code_ln.languageTerm.type_at.should == ["code"]
        end
        it "should understand languageTerm.authority attribute" do
          @iso639_2b_code_ln.languageTerm.authority.should == ["iso639-2b"]
        end
        it "should understand languageTerm value" do
          @iso639_2b_code_ln.languageTerm.text.should == "fre"
          @iso639_2b_code_ln.languageTerm.size.should == 1
        end

        it "should recognize all authority attributes" do
          Mods::AUTHORITY_ATTRIBS.each { |a|
            @mods_rec.from_str("<mods #{@ns_decl}><language><languageTerm #{a}='attr_val'>zzz</languageTerm></language></mods>")
            @mods_rec.language.languageTerm.send(a.to_sym).should == ['attr_val']
          }
        end
      end # <languageTerm> 

      it "should get one language.code_term for each languageTerm element with a type attribute of 'code'" do
        @iso639_2b_code_ln.code_term.size.should == 1
        @iso639_2b_code_ln.code_term.text.should == "fre"
        @mult_code_terms.code_term.size.should == 2
        @mult_code_terms.code_term.first.text.should include("spa")
        @mult_code_terms.code_term[1].text.should == "dut"
      end
      it "should get one language.text_term for each languageTerm element with a type attribute of 'text'" do
        @mult_text_terms.text_term.size.should == 2
        @mult_text_terms.text_term.first.text.should include("Chinese")
        @mult_text_terms.text_term[1].text.should == "Spanish"
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
        @ex_array.each { |t| t.should be_an_instance_of(Nokogiri::XML::NodeSet) }
      end
      it "should have as many members as there are <language> elements in the xml" do
        @ex_array.each { |t| t.size.should == 1 }
      end

      context "<languageTerm> child element" do
        it "should understand languageTerm.type_at attribute" do
          @iso639_2b_code_ln.languageTerm.type_at.should == ["code"]
        end
        it "should understand languageTerm.authority attribute" do
          @iso639_2b_code_ln.languageTerm.authority.should == ["iso639-2b"]
        end
        it "should understand languageTerm value" do
          @iso639_2b_code_ln.languageTerm.text.should == "fre"
          @iso639_2b_code_ln.languageTerm.size.should == 1
        end

        it "should recognize all authority attributes" do
          Mods::AUTHORITY_ATTRIBS.each { |a|
            @mods_rec.from_str("<mods><language><languageTerm #{a}='attr_val'>zzz</languageTerm></language></mods>", false)
            @mods_rec.language.languageTerm.send(a.to_sym).should == ['attr_val']
          }
        end
      end # <languageTerm> 

      it "should get one language.code_term for each languageTerm element with a type attribute of 'code'" do
        @iso639_2b_code_ln.code_term.size.should == 1
        @iso639_2b_code_ln.code_term.text.should == "fre"
        @mult_code_terms.code_term.size.should == 2
        @mult_code_terms.code_term.first.text.should include("spa")
        @mult_code_terms.code_term[1].text.should == "dut"
      end
      it "should get one language.text_term for each languageTerm element with a type attribute of 'text'" do
        @mult_text_terms.text_term.size.should == 2
        @mult_text_terms.text_term.first.text.should include("Chinese")
        @mult_text_terms.text_term[1].text.should == "Spanish"
      end
    end # NOT namespace_aware

  end # basic <language> terminology pieces
  
  # note that Mods::Record.languages tests are in record_spec
  
end