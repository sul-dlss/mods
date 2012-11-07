require 'spec_helper'

describe "Mods <language> Element" do
  before(:all) do
    @mods_rec = Mods::Record.new
    @simple = '<mods><language>Greek</language></mods>'
    @iso639_2b_code = '<mods><language><languageTerm authority="iso639-2b" type="code">fre</languageTerm></language></mods>'
    @iso639_2b_text = '<mods><language><languageTerm authority="iso639-2b" type="text">English</languageTerm></language></mods>'
    @mult_codes = '<mods><language><languageTerm authority="iso639-2b" type="code">per ara, dut</languageTerm></language></mods>'
    @mult_code_terms = '<mods><language><languageTerm authority="iso639-2b" type="code">spa</languageTerm><languageTerm authority="iso639-2b" type="code">dut</languageTerm></language></mods>'
    @mult_text_terms = '<mods><language><languageTerm authority="iso639-2b" type="text">Chinese</languageTerm><languageTerm authority="iso639-2b" type="text">Spanish</languageTerm></language></mods>'
  end

  context "basic language terminology pieces" do
    before(:all) do
      @mods_rec.from_str(@iso639_2b_code)
    end
    it "should understand languageTerm.type_at attribute" do
      @mods_rec.language.languageTerm.type_at.should == ["code"]
    end
    it "should understand languageTerm.authority attribute" do
      @mods_rec.language.languageTerm.authority.should == ["iso639-2b"]
    end
    it "should understand languageTerm value" do
      @mods_rec.language.languageTerm.text.should == "fre"
      @mods_rec.language.languageTerm.size.should == 1
    end
    it "should get one language.code_term for each languageTerm element with a type attribute of 'code'" do
      @mods_rec.language.code_term.size.should == 1
      @mods_rec.language.code_term.text.should == "fre"
      @mods_rec.from_str(@mult_code_terms)
      @mods_rec.language.code_term.size.should == 2
      @mods_rec.language.code_term.first.text.should include("spa")
      @mods_rec.language.code_term[1].text.should == "dut"
    end
    it "should get one language.text_term for each languageTerm element with a type attribute of 'text'" do
      @mods_rec.from_str(@mult_text_terms)
      @mods_rec.language.text_term.size.should == 2
      @mods_rec.language.text_term.first.text.should include("Chinese")
      @mods_rec.language.text_term[1].text.should == "Spanish"
    end
  end
  
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