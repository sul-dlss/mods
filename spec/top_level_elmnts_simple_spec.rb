require 'spec_helper'

describe "Mods Top Level Elements that do not have Sub Elements" do

  before(:all) do
    @mods = Mods::Record.new
  end

  it "should get the text contents of any single simple (cannot have subelements) top level element" do
    Mods::TOP_LEVEL_ELEMENTS_SIMPLE.each { |elname|
      @mods.from_str("<mods><#{elname}>hi</#{elname}></mods>")
      @mods.send(elname.to_sym).should == ["hi"]
    }
  end
  
  it "should get the text contents of any single complex top level element with no subelements" do
    Mods::TOP_LEVEL_ELEMENTS_COMPLEX.each { |elname|
      @mods.from_str("<mods><#{elname}>hi</#{elname}></mods>")
      @mods.send(elname.to_sym).should == ["hi"]
    }
  end
  
  it "should return an array of strings when there are multiple occurrences of simple top level elements" do
    str =  '<mods><note>hi</note><note>hello</note></mods>'
    @mods.from_str(str)
    @mods.note.should == ["hi", "hello"]
  end
  
  it "should deal with camelcase vs. ruby underscore convention" do
    pending "need to implement ruby style version of (element/attribute) method names"
  end
  
end