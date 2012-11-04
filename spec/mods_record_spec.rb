require 'spec_helper'
require 'mods'

describe "Mods Root Element" do
  
  before(:all) do
    @mods = Mods::Record.new
  end
  
  context "subelements" do
    it "should allow individual subelements to be accessed" do
      @mods.from_str('<mods><name><displayForm>Mr. Foo Bar</displayForm></name></mods>')
      @mods.name.should == ["Mr. Foo Bar"]
    end
    it "should print a warning when there are no subelements" do
      expect { @mods.from_str('<mods></mods>') }.to raise_error("actually want to test for warning message")
    end
    it "should raise NoMethodError for incorrect attributes" do
      @mods.from_str("<mods><wrong>ignore</wrong></mods>")
      expect { @mods.name.wrong }.to raise_error(NoMethodError, /undefined method.*wrong/)
    end
  end


  context "attributes" do
    it "should recognize attributes on root node" do
      Mods::Record::ATTRIBUTES.each { |attrb|  
        @mods.from_str("<mods #{attrb}='hello'><name><displayForm>q</displayForm></name></mods>")
        @mods.send(attrb.to_sym).should == 'hello'
      }
    end
    it "should raise NoMethodError for incorrect attributes" do
      @mods.from_str("<mods wrong='ignore'><name><displayForm>q</displayForm></name></mods>")
      expect { @mods.name.wrong }.to raise_error(NoMethodError, /undefined method.*wrong/)
    end
  end
  

end
