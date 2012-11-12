require 'spec_helper'

describe "Mods Top Level Elements that do not have Child Elements" do

  before(:all) do
    @mods_rec = Mods::Record.new
  end

  it "should get the text contents of any single simple (cannot have child elements) top level element" do
    Mods::TOP_LEVEL_ELEMENTS_SIMPLE.each { |elname|
      @mods_rec.from_str("<mods><#{elname}>hi</#{elname}></mods>")
      @mods_rec.send(elname.to_sym).map { |e| e.text }.should == ["hi"]
    }
  end
  
  it "should get the text contents of any single complex top level element instance with no child elements" do
    pending "to be implemented"
    Mods::TOP_LEVEL_ELEMENTS_COMPLEX.each { |elname|
      @mods_rec.from_str("<mods><#{elname}>hi</#{elname}></mods>")
      @mods_rec.send(elname.to_sym).map { |e| e.text }.should == ["hi"]
    }
  end
  
  it "should return an array of strings when there are multiple occurrences of simple top level elements" do
    @mods_rec.from_str('<mods><note>hi</note><note>hello</note></mods>').note.map { |e| e.text }.should == ["hi", "hello"]
  end
  
  it "should deal with camelcase vs. ruby underscore convention" do
    pending "need to implement ruby style version of (element/attribute) method names"
  end
  
  it "<genre> element should recognize authority attributes" do
    pending "to be implemented"
    Mods::AUTHORITY_ATTRIBS.each { |a|  
      @mods_rec.from_str("<mods><genre #{a}='attr_val'>Graphic Novels</genre></mods>").genre.send(a.to_sym).should == 'attr_val'
    }
  end
  
  context "<abstract> child element" do
    it ".abstract.displayLabel should be an accessor for displayLabel attribute on abstract element: <abstract displayLabel='foo'>" do
      @mods_rec.from_str('<mods><abstract displayLabel="Summary">blah blah blah</abstract></mods>')
      @mods_rec.abstract.displayLabel.should == ['Summary']
    end
    it ".abstract.type_at should be an accessor for type attribute on abstract element: <abstract type='foo'>" do
      @mods_rec.from_str('<mods><abstract type="scope and content">blah blah blah</abstract></mods>')
      @mods_rec.abstract.type_at.should == ['scope and content']
    end
  end
  
  context "<accessCondition> child element" do
    before(:all) do
      @acc_cond = @mods_rec.from_str('<mods><accessCondition displayLabel="meh" type="useAndReproduction">blah blah blah</accessCondition></mods>').accessCondition
      @acc_cond2 = @mods_rec.from_str('<mods><accessCondition type="useAndReproduction">All rights reserved.</accessCondition></mods>').accessCondition
    end
    it ".accessCondition.displayLabel should be an accessor for displayLabel attribute on accessCondition element: <accessCondition displayLabel='foo'>" do
      @acc_cond.displayLabel.should == ['meh']
    end
    it ".accessCondition.type_at should be an accessor for type attribute on accessCondition element: <accessCondition type='foo'>" do
      [@acc_cond, @acc_cond2].each { |ac| ac.type_at.should == ['useAndReproduction'] }
    end
  end
  
  context "<classification> child element" do
    before(:all) do
      @class1 = @mods_rec.from_str('<mods><classification authority="ddc" edition="11">683</classification></mods>').classification
      @class2 = @mods_rec.from_str('<mods><classification authority="lcc">JK609.M2</classification></mods>').classification
    end
    it ".classification.authority should be an accessor for authority attribute on classification element: <classification authority='foo'>" do
      @class1.authority.should == ['ddc']
      @class2.authority.should == ['lcc']
    end
    it ".classification.edition should be an accessor for edition attribute on classification element: <classification edition='foo'>" do
      @class1.edition.should == ['11']
    end
    it "should recognize all authority attributes" do
      Mods::AUTHORITY_ATTRIBS.each { |a|  
        @mods_rec.from_str("<mods><classification #{a}='attr_val'>zzz</classification></mods>")
        @mods_rec.classification.send(a.to_sym).should == ['attr_val']
      }
    end
  end
  
end