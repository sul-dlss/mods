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
      @mods_rec.from_str('<mods><abstract type="Scope and Contents note">blah blah blah</abstract></mods>')
      @mods_rec.abstract.type_at.should == ['Scope and Contents note']
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
  
  context "<extension> child element" do
    before(:all) do
      @ext = @mods_rec.from_str('<mods><extension xmlns:dcterms="http://purl.org/dc/terms/" >
      	<dcterms:modified>2003-03-24</dcterms:modified>
      </extension></mods>').extension
    end
    it ".extension.displayLabel should be an accessor for displayLabel attribute on extension element: <extension displayLabel='foo'>" do
      @mods_rec.from_str('<mods><extension displayLabel="something">blah blah blah</extension></mods>')
      @mods_rec.extension.displayLabel.should == ['something']
    end
  end

  context "<genre> child element" do
    before(:all) do
      @genre1 = @mods_rec.from_str('<mods><genre authority="marcgt">map</genre></mods>').genre
      @genre1 = @mods_rec.from_str('<mods><genre authority="marcgt">map</genre></mods>').genre
    end
    it ".genre.displayLabel should be an accessor for displayLabel attribute on genre element: <genre displayLabel='foo'>" do
      @mods_rec.from_str('<mods><genre displayLabel="something">blah blah blah</genre></mods>')
      @mods_rec.genre.displayLabel.should == ['something']
    end
    it ".genre.type_at should be an accessor for type attribute on genre element: <genre type='foo'>" do
      @mods_rec.from_str('<mods><genre type="maybe">blah blah blah</genre></mods>')
      @mods_rec.genre.type_at.should == ['maybe']
    end
    it ".genre.usage should be an accessor for usage attribute on genre element: <genre usage='foo'>" do
      @mods_rec.from_str('<mods><genre usage="fer sure">blah blah blah</genre></mods>')
      @mods_rec.genre.usage.should == ['fer sure']
    end
    it "should recognize all authority attributes" do
      Mods::AUTHORITY_ATTRIBS.each { |a|  
        @mods_rec.from_str("<mods><genre #{a}='attr_val'>zzz</genre></mods>")
        @mods_rec.genre.send(a.to_sym).should == ['attr_val']
      }
    end
  end

  context "<typeOfResource> child element" do
    before(:all) do
      '<typeOfResource manuscript="yes">mixed material</typeOfResource>'
    end
  end
  
end