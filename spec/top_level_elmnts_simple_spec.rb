require 'spec_helper'

describe "Mods Top Level Elements that do not have Child Elements" do

  before(:all) do
    @mods_rec = Mods::Record.new
  end

  it "should get the text contents of any single simple (cannot have child elements) top level element" do
    Mods::TOP_LEVEL_ELEMENTS_SIMPLE.each { |elname|
      @mods_rec.from_str("<mods><#{elname}>hi</#{elname}></mods>")
      @mods_rec.send(elname.to_sym).should == ["hi"]
    }
  end
  
  it "should get the text contents of any single complex top level element instance with no child elements" do
    pending "to be implemented"
    Mods::TOP_LEVEL_ELEMENTS_COMPLEX.each { |elname|
      @mods_rec.from_str("<mods><#{elname}>hi</#{elname}></mods>")
      @mods_rec.send(elname.to_sym).should == ["hi"]
    }
  end
  
  it "should return an array of strings when there are multiple occurrences of simple top level elements" do
    @mods_rec.from_str('<mods><note>hi</note><note>hello</note></mods>').note.should == ["hi", "hello"]
  end
  
  it "should deal with camelcase vs. ruby underscore convention" do
    pending "need to implement ruby style version of (element/attribute) method names"
  end
  
end