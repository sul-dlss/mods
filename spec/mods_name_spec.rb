require 'spec_helper'
require 'mods'

describe "Mods Name Elements" do
  
  before(:all) do
    @mods = Mods::Record.new
  end

  context "name element" do
    it "should return an array with a single value when there is a single name element" do
      str =  '<mods><name><displayForm>Mr. Foo Bar</displayForm></name></mods>'
      @mods.from_str(str)
      @mods.name.should == ["Mr. Foo Bar"]
    end
    it "should return an array of values when there are multiple name elements" do
      str =  '<mods><name><displayForm>Mr. Foo Bar</displayForm></name><name><displayForm>Mrs. Foo Bar</displayForm></name></mods>'
      @mods.from_str(str)
      @mods.name.should == ["Mr. Foo Bar", "Mrs. Foo Bar"]
    end
    it "should allow individual subelements to be accessed" do
      str =  '<mods><name><displayForm>Mr. Foo Bar</displayForm></name></mods>'
      @mods.from_str(str)
      @mods.name.displayForm.should == ["Mr. Foo Bar"]
    end
    it "should print a warning when there are no subelements" do
      str =  '<mods><name>tigers</name></mods>'
      @mods.from_str(str)
      pending "to be implemented"
    end
    it "should do stuff with attributes" do
      pending "to be implemented"
    end
  end
  
  context "value for mods.name" do
    it "should prefer displayForm subelement value to concat of namePart subelement values" do
      str =  '<mods><name><displayForm>Mr. Foo Bar</displayForm><namePart>a</namePart><namePart>b</namePart></name></mods>'
      @mods.from_str(str)
      @mods.name.should == ["Mr. Foo Bar"]
    end
    it "should give concat of nameParts if there is no displayForm subelement" do
      str =  '<mods><name><namePart>a</namePart><namePart>b</namePart></name></mods>'
      @mods.from_str(str)
      @mods.name.should == ["a b"]
    end
    it "should order the namePart elements according to their type attribute, if present" do
      pending "to be implemented"
    end
    it "should combine any and all subelements into a useful string" do
      pending "to be implemented"
      @mods.name.should == ["first name pieces", "second name pieces"]
    end
    
  end
  

  context "corporate names" do
    it "should include name elements with type attr = corporate" do
      pending "to be implemented"
    end
    it "should not include name elements with type attr != corporate" do
      pending "to be implemented"
    end
  end

  context "namePart subelement" do


    it "should get the text contents of any single simple (cannot have subelements) top level element" do
      Mods::TOP_LEVEL_ELEMENTS_SIMPLE.each { |elname|
        @mods.from_str("<mods><#{elname}>hi</#{elname}></mods>")
        @mods.send(elname.to_sym).should == ["hi"]
      }
    end
    
    it "should return an array of strings when there are multiple occurrences of simple top level elements" do
      str =  '<mods><note>hi</note><note>hello</note></mods>'
      @mods.from_str(str)
      @mods.note.should == ["hi", "hello"]
    end
    
    
  end
  
  context "role subelement" do
    it "should work when there is no subelement" do
      pending "to be implemented"
    end
    it "should work when there is a roleTerm subelement" do
      pending "to be implemented"
    end
    it "should do something when there is some other illegal subelement" do
      pending "to be implemented"
    end
    it "should translate the marc relator code into text" do
      pending "to be implemented"
    end
  end
  
end