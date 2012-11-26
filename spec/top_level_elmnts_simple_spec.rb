require 'spec_helper'

describe "Mods Top Level Elements that do not have Child Elements" do

  before(:all) do
    @mods_rec = Mods::Record.new
  end
  
  it "should deal with camelcase vs. ruby underscore convention" do
    pending "need to implement ruby style version of (element/attribute) method names"
  end

  it "should get the text contents of any single complex top level element instance with no child elements" do
    pending "to be implemented"
    Mods::TOP_LEVEL_ELEMENTS_COMPLEX.each { |elname|
      @mods_rec.from_str("<mods><#{elname}>hi</#{elname}></mods>", false)
      @mods_rec.send(elname.to_sym).map { |e| e.text }.should == ["hi"]
    }
  end

  context "parsing without namespaces" do

    it "should get the text contents of any single simple (cannot have child elements) top level element" do
      Mods::TOP_LEVEL_ELEMENTS_SIMPLE.each { |elname|
        @mods_rec.from_str("<mods><#{elname}>hi</#{elname}></mods>", false)
        @mods_rec.send(elname.to_sym).map { |e| e.text }.should == ["hi"]
      }
    end

    it "should return an array of strings when there are multiple occurrences of simple top level elements" do
      @mods_rec.from_str('<mods><note>hi</note><note>hello</note></mods>', false).note.map { |e| e.text }.should == ["hi", "hello"]
    end
    
    context "<abstract> child element" do
      it ".abstract.displayLabel should be an accessor for displayLabel attribute on abstract element: <abstract displayLabel='foo'>" do
        @mods_rec.from_str('<mods><abstract displayLabel="Summary">blah blah blah</abstract></mods>', false)
        @mods_rec.abstract.displayLabel.should == ['Summary']
      end
      it ".abstract.type_at should be an accessor for type attribute on abstract element: <abstract type='foo'>" do
        @mods_rec.from_str('<mods><abstract type="Scope and Contents note">blah blah blah</abstract></mods>', false)
        @mods_rec.abstract.type_at.should == ['Scope and Contents note']
      end
    end

    context "<accessCondition> child element" do
      before(:all) do
        @acc_cond = @mods_rec.from_str('<mods><accessCondition displayLabel="meh" type="useAndReproduction">blah blah blah</accessCondition></mods>', false).accessCondition
        @acc_cond2 = @mods_rec.from_str('<mods><accessCondition type="useAndReproduction">All rights reserved.</accessCondition></mods>', false).accessCondition
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
        @class1 = @mods_rec.from_str('<mods><classification authority="ddc" edition="11">683</classification></mods>', false).classification
        @class2 = @mods_rec.from_str('<mods><classification authority="lcc">JK609.M2</classification></mods>', false).classification
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
          @mods_rec.from_str("<mods><classification #{a}='attr_val'>zzz</classification></mods>", false)
          @mods_rec.classification.send(a.to_sym).should == ['attr_val']
        }
      end
    end

    context "<extension> child element" do
      before(:all) do
        @ext = @mods_rec.from_str('<mods><extension xmlns:dcterms="http://purl.org/dc/terms/" >
        	<dcterms:modified>2003-03-24</dcterms:modified>
        </extension></mods>', false).extension
      end
      it ".extension.displayLabel should be an accessor for displayLabel attribute on extension element: <extension displayLabel='foo'>" do
        @mods_rec.from_str('<mods><extension displayLabel="something">blah blah blah</extension></mods>', false)
        @mods_rec.extension.displayLabel.should == ['something']
      end
    end

    context "<genre> child element" do
      it ".genre.displayLabel should be an accessor for displayLabel attribute on genre element: <genre displayLabel='foo'>" do
        @mods_rec.from_str('<mods><genre displayLabel="something">blah blah blah</genre></mods>', false)
        @mods_rec.genre.displayLabel.should == ['something']
      end
      it ".genre.type_at should be an accessor for type attribute on genre element: <genre type='foo'>" do
        @mods_rec.from_str('<mods><genre type="maybe">blah blah blah</genre></mods>', false)
        @mods_rec.genre.type_at.should == ['maybe']
      end
      it ".genre.usage should be an accessor for usage attribute on genre element: <genre usage='foo'>" do
        @mods_rec.from_str('<mods><genre usage="fer sure">blah blah blah</genre></mods>', false)
        @mods_rec.genre.usage.should == ['fer sure']
      end
      it "should recognize all authority attributes" do
        Mods::AUTHORITY_ATTRIBS.each { |a|  
          @mods_rec.from_str("<mods><genre #{a}='attr_val'>zzz</genre></mods>", false)
          @mods_rec.genre.send(a.to_sym).should == ['attr_val']
        }
      end
    end

    context "<identifier> child element" do
      before(:all) do
        @id = @mods_rec.from_str('<mods><identifier displayLabel="book_number" type="local">70</identifier></mods>', false).identifier
      end
      it ".identifier.displayLabel should be an accessor for displayLabel attribute on identifier element: <identifier displayLabel='foo'>" do
        @id.displayLabel.should == ['book_number']
      end
      it ".identifier.invalid should be an accessor for invalid attribute on identifier element: <identifier invalid='foo'>" do
        @mods_rec.from_str('<mods> <identifier type="isbn" invalid="yes">0877780116</identifier></mods>', false)
        @mods_rec.identifier.invalid.should == ['yes']
      end
      it ".identifier.type_at should be an accessor for type attribute on identifier element: <identifier type='foo'>" do
        @id.type_at.should == ['local']
      end
    end

    context "<note> child element" do
      it ".note.displayLabel should be an accessor for displayLabel attribute on note element: <note displayLabel='foo'>" do
        @mods_rec.from_str('<mods><note displayLabel="state_note">blah</note></mods>', false)
        @mods_rec.note.displayLabel.should == ['state_note']
      end
      it ".note.id_at should be an accessor for ID attribute on note element: <note ID='foo'>" do
        @mods_rec.from_str('<mods><note ID="foo">blah blah blah</note></mods>', false)
        @mods_rec.note.id_at.should == ['foo']
      end
      it ".note.type_at should be an accessor for type attribute on note element: <note type='foo'>" do
        @mods_rec.from_str('<mods><note type="content">blah</note></mods>', false)
        @mods_rec.note.type_at.should == ['content']
      end
    end

    context "<tableOfContents> child element" do
      it ".tableOfContents.displayLabel should be an accessor for displayLabel attribute on tableOfContents element: <tableOfContents displayLabel='foo'>" do
        @mods_rec.from_str('<mods><tableOfContents displayLabel="Chapters included in book">blah blah</tableOfContents></mods>', false)
        @mods_rec.tableOfContents.displayLabel.should == ['Chapters included in book']
      end
      it ".tableOfContents.shareable should be an accessor for shareable attribute on tableOfContents element: <tableOfContents shareable='foo'>" do
        @mods_rec.from_str('<mods><tableOfContents shareable="no">blah blah blah</tableOfContents></mods>', false)
        @mods_rec.tableOfContents.shareable.should == ['no']
      end
      it ".tableOfContents.type_at should be an accessor for type attribute on tableOfContents element: <tableOfContents type='foo'>" do
        @mods_rec.from_str('<mods><tableOfContents type="partial contents">blah blah</tableOfContents></mods>', false)
        @mods_rec.tableOfContents.type_at.should == ['partial contents']
      end
    end

    context "<targetAudience> child element" do
      it ".targetAudience.displayLabel should be an accessor for displayLabel attribute on targetAudience element: <targetAudience displayLabel='foo'>" do
        @mods_rec.from_str('<mods><targetAudience displayLabel="ta da">blah blah</targetAudience></mods>', false)
        @mods_rec.targetAudience.displayLabel.should == ['ta da']
      end
      it "should recognize all authority attributes" do
        Mods::AUTHORITY_ATTRIBS.each { |a|  
          @mods_rec.from_str("<mods><targetAudience #{a}='attr_val'>zzz</targetAudience></mods>", false)
          @mods_rec.targetAudience.send(a.to_sym).should == ['attr_val']
        }
      end
    end

    context "<typeOfResource> child element" do
      before(:all) do
        '<typeOfResource manuscript="yes">mixed material</typeOfResource>'
      end
      it ".typeOfResource.collection should be an accessor for collection attribute on typeOfResource element: <typeOfResource collection='foo'>" do
        @mods_rec.from_str('<mods><typeOfResource collection="yes">blah blah blah</typeOfResource></mods>', false)
        @mods_rec.typeOfResource.collection.should == ['yes']
      end
      it ".typeOfResource.displayLabel should be an accessor for displayLabel attribute on typeOfResource element: <typeOfResource displayLabel='foo'>" do
        @mods_rec.from_str('<mods><typeOfResource displayLabel="Summary">blah blah blah</typeOfResource></mods>', false)
        @mods_rec.typeOfResource.displayLabel.should == ['Summary']
      end
      it ".typeOfResource.manuscript should be an accessor for manuscript attribute on typeOfResource element: <typeOfResource manuscript='foo'>" do
        @mods_rec.from_str('<mods><typeOfResource manuscript="yes">blah blah blah</typeOfResource></mods>', false)
        @mods_rec.typeOfResource.manuscript.should == ['yes']
      end
      it ".typeOfResource.usage should be an accessor for usage attribute on typeOfResource element: <typeOfResource usage='foo'>" do
        @mods_rec.from_str('<mods><typeOfResource usage="fer sure">blah blah blah</typeOfResource></mods>', false)
        @mods_rec.typeOfResource.usage.should == ['fer sure']
      end
    end
    
  end # context without namespaces
   
  context "parsing with namespaces" do

    before(:all) do
      @mods_el_w_ns = '<mods xmlns="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-2.xsd">'
    end

    it "should get the text contents of any single simple (cannot have child elements) top level element" do
      Mods::TOP_LEVEL_ELEMENTS_SIMPLE.each { |elname|
        @mods_rec.from_str(@mods_el_w_ns + "<#{elname}>hi</#{elname}></mods>")
        @mods_rec.send(elname.to_sym).map { |e| e.text }.should == ["hi"]
      }
    end

    it "should return an array of strings when there are multiple occurrences of simple top level elements" do
      @mods_rec.from_str(@mods_el_w_ns + '<note>hi</note><note>hello</note></mods>').note.map { |e| e.text }.should == ["hi", "hello"]
    end

    context "<abstract> child element" do
      it ".abstract.displayLabel should be an accessor for displayLabel attribute on abstract element: <abstract displayLabel='foo'>" do
        @mods_rec.from_str(@mods_el_w_ns + '<abstract displayLabel="Summary">blah blah blah</abstract></mods>')
        @mods_rec.abstract.displayLabel.should == ['Summary']
      end
      it ".abstract.type_at should be an accessor for type attribute on abstract element: <abstract type='foo'>" do
        @mods_rec.from_str(@mods_el_w_ns + '<abstract type="Scope and Contents note">blah blah blah</abstract></mods>')
        @mods_rec.abstract.type_at.should == ['Scope and Contents note']
      end
    end

    context "<accessCondition> child element" do
      before(:all) do
        @acc_cond = @mods_rec.from_str(@mods_el_w_ns + '<accessCondition displayLabel="meh" type="useAndReproduction">blah blah blah</accessCondition></mods>').accessCondition
        @acc_cond2 = @mods_rec.from_str(@mods_el_w_ns + '<accessCondition type="useAndReproduction">All rights reserved.</accessCondition></mods>').accessCondition
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
        @class1 = @mods_rec.from_str(@mods_el_w_ns + '<classification authority="ddc" edition="11">683</classification></mods>').classification
        @class2 = @mods_rec.from_str(@mods_el_w_ns + '<classification authority="lcc">JK609.M2</classification></mods>').classification
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
          @mods_rec.from_str(@mods_el_w_ns + "<classification #{a}='attr_val'>zzz</classification></mods>")
          @mods_rec.classification.send(a.to_sym).should == ['attr_val']
        }
      end
    end

    context "<extension> child element" do
      before(:all) do
        @ext = @mods_rec.from_str(@mods_el_w_ns + '<extension xmlns:dcterms="http://purl.org/dc/terms/" >
        	<dcterms:modified>2003-03-24</dcterms:modified>
        </extension></mods>').extension
      end
      it ".extension.displayLabel should be an accessor for displayLabel attribute on extension element: <extension displayLabel='foo'>" do
        @mods_rec.from_str(@mods_el_w_ns + '<extension displayLabel="something">blah blah blah</extension></mods>')
        @mods_rec.extension.displayLabel.should == ['something']
      end
    end

    context "<genre> child element" do
      it ".genre.displayLabel should be an accessor for displayLabel attribute on genre element: <genre displayLabel='foo'>" do
        @mods_rec.from_str(@mods_el_w_ns + '<genre displayLabel="something">blah blah blah</genre></mods>')
        @mods_rec.genre.displayLabel.should == ['something']
      end
      it ".genre.type_at should be an accessor for type attribute on genre element: <genre type='foo'>" do
        @mods_rec.from_str(@mods_el_w_ns + '<genre type="maybe">blah blah blah</genre></mods>')
        @mods_rec.genre.type_at.should == ['maybe']
      end
      it ".genre.usage should be an accessor for usage attribute on genre element: <genre usage='foo'>" do
        @mods_rec.from_str(@mods_el_w_ns + '<genre usage="fer sure">blah blah blah</genre></mods>')
        @mods_rec.genre.usage.should == ['fer sure']
      end
      it "should recognize all authority attributes" do
        Mods::AUTHORITY_ATTRIBS.each { |a|  
          @mods_rec.from_str(@mods_el_w_ns + "<genre #{a}='attr_val'>zzz</genre></mods>")
          @mods_rec.genre.send(a.to_sym).should == ['attr_val']
        }
      end
    end

    context "<identifier> child element" do
      before(:all) do
        @id = @mods_rec.from_str(@mods_el_w_ns + '<identifier displayLabel="book_number" type="local">70</identifier></mods>').identifier
      end
      it ".identifier.displayLabel should be an accessor for displayLabel attribute on identifier element: <identifier displayLabel='foo'>" do
        @id.displayLabel.should == ['book_number']
      end
      it ".identifier.invalid should be an accessor for invalid attribute on identifier element: <identifier invalid='foo'>" do
        @mods_rec.from_str(@mods_el_w_ns + '<identifier type="isbn" invalid="yes">0877780116</identifier></mods>')
        @mods_rec.identifier.invalid.should == ['yes']
      end
      it ".identifier.type_at should be an accessor for type attribute on identifier element: <identifier type='foo'>" do
        @id.type_at.should == ['local']
      end
    end

    context "<note> child element" do
      it ".note.displayLabel should be an accessor for displayLabel attribute on note element: <note displayLabel='foo'>" do
        @mods_rec.from_str(@mods_el_w_ns + '<note displayLabel="state_note">blah</note></mods>')
        @mods_rec.note.displayLabel.should == ['state_note']
      end
      it ".note.id_at should be an accessor for ID attribute on note element: <note ID='foo'>" do
        @mods_rec.from_str(@mods_el_w_ns + '<note ID="foo">blah blah blah</note></mods>')
        @mods_rec.note.id_at.should == ['foo']
      end
      it ".note.type_at should be an accessor for type attribute on note element: <note type='foo'>" do
        @mods_rec.from_str(@mods_el_w_ns + '<note type="content">blah</note></mods>')
        @mods_rec.note.type_at.should == ['content']
      end
    end

    context "<tableOfContents> child element" do
      it ".tableOfContents.displayLabel should be an accessor for displayLabel attribute on tableOfContents element: <tableOfContents displayLabel='foo'>" do
        @mods_rec.from_str(@mods_el_w_ns + '<tableOfContents displayLabel="Chapters included in book">blah blah</tableOfContents></mods>')
        @mods_rec.tableOfContents.displayLabel.should == ['Chapters included in book']
      end
      it ".tableOfContents.shareable should be an accessor for shareable attribute on tableOfContents element: <tableOfContents shareable='foo'>" do
        @mods_rec.from_str(@mods_el_w_ns + '<tableOfContents shareable="no">blah blah blah</tableOfContents></mods>')
        @mods_rec.tableOfContents.shareable.should == ['no']
      end
      it ".tableOfContents.type_at should be an accessor for type attribute on tableOfContents element: <tableOfContents type='foo'>" do
        @mods_rec.from_str(@mods_el_w_ns + '<tableOfContents type="partial contents">blah blah</tableOfContents></mods>')
        @mods_rec.tableOfContents.type_at.should == ['partial contents']
      end
    end

    context "<targetAudience> child element" do
      it ".targetAudience.displayLabel should be an accessor for displayLabel attribute on targetAudience element: <targetAudience displayLabel='foo'>" do
        @mods_rec.from_str(@mods_el_w_ns + '<targetAudience displayLabel="ta da">blah blah</targetAudience></mods>')
        @mods_rec.targetAudience.displayLabel.should == ['ta da']
      end
      it "should recognize all authority attributes" do
        Mods::AUTHORITY_ATTRIBS.each { |a|  
          @mods_rec.from_str(@mods_el_w_ns + "<targetAudience #{a}='attr_val'>zzz</targetAudience></mods>")
          @mods_rec.targetAudience.send(a.to_sym).should == ['attr_val']
        }
      end
    end

    context "<typeOfResource> child element" do
      it ".typeOfResource.collection should be an accessor for collection attribute on typeOfResource element: <typeOfResource collection='foo'>" do
        @mods_rec.from_str(@mods_el_w_ns + '<typeOfResource collection="yes">blah blah blah</typeOfResource></mods>')
        @mods_rec.typeOfResource.collection.should == ['yes']
      end
      it ".typeOfResource.displayLabel should be an accessor for displayLabel attribute on typeOfResource element: <typeOfResource displayLabel='foo'>" do
        @mods_rec.from_str(@mods_el_w_ns + '<typeOfResource displayLabel="Summary">blah blah blah</typeOfResource></mods>')
        @mods_rec.typeOfResource.displayLabel.should == ['Summary']
      end
      it ".typeOfResource.manuscript should be an accessor for manuscript attribute on typeOfResource element: <typeOfResource manuscript='foo'>" do
        @mods_rec.from_str(@mods_el_w_ns + '<typeOfResource manuscript="yes">blah blah blah</typeOfResource></mods>')
        @mods_rec.typeOfResource.manuscript.should == ['yes']
      end
      it ".typeOfResource.usage should be an accessor for usage attribute on typeOfResource element: <typeOfResource usage='foo'>" do
        @mods_rec.from_str(@mods_el_w_ns + '<typeOfResource usage="fer sure">blah blah blah</typeOfResource></mods>')
        @mods_rec.typeOfResource.usage.should == ['fer sure']
      end
    end
    
  end # parsing with namespaces
  
  
end