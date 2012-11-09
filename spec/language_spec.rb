require 'spec_helper'

describe "Mods <language> Element" do
  before(:all) do
    @mods_rec = Mods::Record.new
    @simple = '<mods><language>Greek</language></mods>'
    @simple_ln = @mods_rec.from_str(@simple).language
    @iso639_2b_code = '<mods><language><languageTerm authority="iso639-2b" type="code">fre</languageTerm></language></mods>'
    @iso639_2b_code_ln = @mods_rec.from_str(@iso639_2b_code).language
    @iso639_2b_text = '<mods><language><languageTerm authority="iso639-2b" type="text">English</languageTerm></language></mods>'
    @iso639_2b_text_ln = @mods_rec.from_str(@iso639_2b_text).language
    @mult_codes = '<mods><language><languageTerm authority="iso639-2b" type="code">per ara, dut</languageTerm></language></mods>'
    @mult_codes_ln = @mods_rec.from_str(@mult_codes).language
    mult_code_terms = '<mods><language><languageTerm authority="iso639-2b" type="code">spa</languageTerm><languageTerm authority="iso639-2b" type="code">dut</languageTerm></language></mods>'
    @mult_code_terms = @mods_rec.from_str(mult_code_terms).language
    mult_text_terms = '<mods><language><languageTerm authority="iso639-2b" type="text">Chinese</languageTerm><languageTerm authority="iso639-2b" type="text">Spanish</languageTerm></language></mods>'
    @mult_text_terms = @mods_rec.from_str(mult_text_terms).language
    @ex_array = [@simple_ln, @iso639_2b_code_ln, @iso639_2b_text_ln, @mult_codes_ln, @mult_code_terms, @mult_text_terms]
  end

  context "basic <language> terminology pieces" do
    before(:all) do
      @mods_rec.from_str(@iso639_2b_code)
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
          @mods_rec.from_str("<mods><language><languageTerm #{a}='attr_val'>zzz</languageTerm></language></mods>")
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
  end # basic <language> terminology pieces
  
  context "Mods::Record.languages convenience method" do
    
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
  
end