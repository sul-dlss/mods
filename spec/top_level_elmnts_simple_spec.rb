require 'spec_helper'
require 'mods'

describe "Mods Top Level Elements that do not have Sub Elements" do

  before(:all) do
    @mods = Mods::Record.new
  end

  it "should get the text contents of any single simple top level element" do
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