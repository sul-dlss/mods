require 'spec_helper'

describe "Mods Top Level Elements that do not have Child Elements" do

  before(:all) do
    @mods_rec = Mods::Record.new
  end

  it "should deal with camelcase vs. ruby underscore convention" do
    skip "need to implement ruby style version of (element/attribute) method names"
  end

  it "should get the text contents of any single complex top level element instance with no child elements" do
    skip "to be implemented"
    Mods::TOP_LEVEL_ELEMENTS_COMPLEX.each { |elname|
      @mods_rec.from_str("<mods><#{elname}>hi</#{elname}></mods>", false)
      expect(@mods_rec.send(elname.to_sym).map { |e| e.text }).to eq(["hi"])
    }
  end

  context "parsing without namespaces" do

    it "should get the text contents of any single simple (cannot have child elements) top level element" do
      Mods::TOP_LEVEL_ELEMENTS_SIMPLE.each { |elname|
        @mods_rec.from_str("<mods><#{elname}>hi</#{elname}></mods>", false)
        expect(@mods_rec.send(elname.to_sym).map { |e| e.text }).to eq(["hi"])
      }
    end

    it "should return an array of strings when there are multiple occurrences of simple top level elements" do
      expect(@mods_rec.from_str('<mods><note>hi</note><note>hello</note></mods>', false).note.map { |e| e.text }).to eq(["hi", "hello"])
    end

    context "<abstract> child element" do
      it ".abstract.displayLabel should be an accessor for displayLabel attribute on abstract element: <abstract displayLabel='foo'>" do
        @mods_rec.from_str('<mods><abstract displayLabel="Summary">blah blah blah</abstract></mods>', false)
        expect(@mods_rec.abstract.displayLabel).to eq(['Summary'])
      end
      it ".abstract.type_at should be an accessor for type attribute on abstract element: <abstract type='foo'>" do
        @mods_rec.from_str('<mods><abstract type="Scope and Contents note">blah blah blah</abstract></mods>', false)
        expect(@mods_rec.abstract.type_at).to eq(['Scope and Contents note'])
      end
    end

    context "<accessCondition> child element" do
      before(:all) do
        @acc_cond = @mods_rec.from_str('<mods><accessCondition displayLabel="meh" type="useAndReproduction">blah blah blah</accessCondition></mods>', false).accessCondition
        @acc_cond2 = @mods_rec.from_str('<mods><accessCondition type="useAndReproduction">All rights reserved.</accessCondition></mods>', false).accessCondition
      end
      it ".accessCondition.displayLabel should be an accessor for displayLabel attribute on accessCondition element: <accessCondition displayLabel='foo'>" do
        expect(@acc_cond.displayLabel).to eq(['meh'])
      end
      it ".accessCondition.type_at should be an accessor for type attribute on accessCondition element: <accessCondition type='foo'>" do
        [@acc_cond, @acc_cond2].each { |ac| expect(ac.type_at).to eq(['useAndReproduction']) }
      end
    end

    context "<classification> child element" do
      before(:all) do
        @class1 = @mods_rec.from_str('<mods><classification authority="ddc" edition="11">683</classification></mods>', false).classification
        @class2 = @mods_rec.from_str('<mods><classification authority="lcc">JK609.M2</classification></mods>', false).classification
      end
      it ".classification.authority should be an accessor for authority attribute on classification element: <classification authority='foo'>" do
        expect(@class1.authority).to eq(['ddc'])
        expect(@class2.authority).to eq(['lcc'])
      end
      it ".classification.edition should be an accessor for edition attribute on classification element: <classification edition='foo'>" do
        expect(@class1.edition).to eq(['11'])
      end
      it "should recognize all authority attributes" do
        Mods::AUTHORITY_ATTRIBS.each { |a|
          @mods_rec.from_str("<mods><classification #{a}='attr_val'>zzz</classification></mods>", false)
          expect(@mods_rec.classification.send(a.to_sym)).to eq(['attr_val'])
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
        expect(@mods_rec.extension.displayLabel).to eq(['something'])
      end
    end

    context "<genre> child element" do
      it ".genre.displayLabel should be an accessor for displayLabel attribute on genre element: <genre displayLabel='foo'>" do
        @mods_rec.from_str('<mods><genre displayLabel="something">blah blah blah</genre></mods>', false)
        expect(@mods_rec.genre.displayLabel).to eq(['something'])
      end
      it ".genre.type_at should be an accessor for type attribute on genre element: <genre type='foo'>" do
        @mods_rec.from_str('<mods><genre type="maybe">blah blah blah</genre></mods>', false)
        expect(@mods_rec.genre.type_at).to eq(['maybe'])
      end
      it ".genre.usage should be an accessor for usage attribute on genre element: <genre usage='foo'>" do
        @mods_rec.from_str('<mods><genre usage="fer sure">blah blah blah</genre></mods>', false)
        expect(@mods_rec.genre.usage).to eq(['fer sure'])
      end
      it "should recognize all authority attributes" do
        Mods::AUTHORITY_ATTRIBS.each { |a|
          @mods_rec.from_str("<mods><genre #{a}='attr_val'>zzz</genre></mods>", false)
          expect(@mods_rec.genre.send(a.to_sym)).to eq(['attr_val'])
        }
      end
    end

    context "<identifier> child element" do
      before(:all) do
        @id = @mods_rec.from_str('<mods><identifier displayLabel="book_number" type="local">70</identifier></mods>', false).identifier
      end
      it ".identifier.displayLabel should be an accessor for displayLabel attribute on identifier element: <identifier displayLabel='foo'>" do
        expect(@id.displayLabel).to eq(['book_number'])
      end
      it ".identifier.invalid should be an accessor for invalid attribute on identifier element: <identifier invalid='foo'>" do
        @mods_rec.from_str('<mods> <identifier type="isbn" invalid="yes">0877780116</identifier></mods>', false)
        expect(@mods_rec.identifier.invalid).to eq(['yes'])
      end
      it ".identifier.type_at should be an accessor for type attribute on identifier element: <identifier type='foo'>" do
        expect(@id.type_at).to eq(['local'])
      end
    end

    context "<note> child element" do
      it ".note.displayLabel should be an accessor for displayLabel attribute on note element: <note displayLabel='foo'>" do
        @mods_rec.from_str('<mods><note displayLabel="state_note">blah</note></mods>', false)
        expect(@mods_rec.note.displayLabel).to eq(['state_note'])
      end
      it ".note.id_at should be an accessor for ID attribute on note element: <note ID='foo'>" do
        @mods_rec.from_str('<mods><note ID="foo">blah blah blah</note></mods>', false)
        expect(@mods_rec.note.id_at).to eq(['foo'])
      end
      it ".note.type_at should be an accessor for type attribute on note element: <note type='foo'>" do
        @mods_rec.from_str('<mods><note type="content">blah</note></mods>', false)
        expect(@mods_rec.note.type_at).to eq(['content'])
      end
    end

    context "<tableOfContents> child element" do
      it ".tableOfContents.displayLabel should be an accessor for displayLabel attribute on tableOfContents element: <tableOfContents displayLabel='foo'>" do
        @mods_rec.from_str('<mods><tableOfContents displayLabel="Chapters included in book">blah blah</tableOfContents></mods>', false)
        expect(@mods_rec.tableOfContents.displayLabel).to eq(['Chapters included in book'])
      end
      it ".tableOfContents.shareable should be an accessor for shareable attribute on tableOfContents element: <tableOfContents shareable='foo'>" do
        @mods_rec.from_str('<mods><tableOfContents shareable="no">blah blah blah</tableOfContents></mods>', false)
        expect(@mods_rec.tableOfContents.shareable).to eq(['no'])
      end
      it ".tableOfContents.type_at should be an accessor for type attribute on tableOfContents element: <tableOfContents type='foo'>" do
        @mods_rec.from_str('<mods><tableOfContents type="partial contents">blah blah</tableOfContents></mods>', false)
        expect(@mods_rec.tableOfContents.type_at).to eq(['partial contents'])
      end
    end

    context "<targetAudience> child element" do
      it ".targetAudience.displayLabel should be an accessor for displayLabel attribute on targetAudience element: <targetAudience displayLabel='foo'>" do
        @mods_rec.from_str('<mods><targetAudience displayLabel="ta da">blah blah</targetAudience></mods>', false)
        expect(@mods_rec.targetAudience.displayLabel).to eq(['ta da'])
      end
      it "should recognize all authority attributes" do
        Mods::AUTHORITY_ATTRIBS.each { |a|
          @mods_rec.from_str("<mods><targetAudience #{a}='attr_val'>zzz</targetAudience></mods>", false)
          expect(@mods_rec.targetAudience.send(a.to_sym)).to eq(['attr_val'])
        }
      end
    end

    context "<typeOfResource> child element" do
      before(:all) do
        '<typeOfResource manuscript="yes">mixed material</typeOfResource>'
      end
      it ".typeOfResource.collection should be an accessor for collection attribute on typeOfResource element: <typeOfResource collection='foo'>" do
        @mods_rec.from_str('<mods><typeOfResource collection="yes">blah blah blah</typeOfResource></mods>', false)
        expect(@mods_rec.typeOfResource.collection).to eq(['yes'])
      end
      it ".typeOfResource.displayLabel should be an accessor for displayLabel attribute on typeOfResource element: <typeOfResource displayLabel='foo'>" do
        @mods_rec.from_str('<mods><typeOfResource displayLabel="Summary">blah blah blah</typeOfResource></mods>', false)
        expect(@mods_rec.typeOfResource.displayLabel).to eq(['Summary'])
      end
      it ".typeOfResource.manuscript should be an accessor for manuscript attribute on typeOfResource element: <typeOfResource manuscript='foo'>" do
        @mods_rec.from_str('<mods><typeOfResource manuscript="yes">blah blah blah</typeOfResource></mods>', false)
        expect(@mods_rec.typeOfResource.manuscript).to eq(['yes'])
      end
      it ".typeOfResource.usage should be an accessor for usage attribute on typeOfResource element: <typeOfResource usage='foo'>" do
        @mods_rec.from_str('<mods><typeOfResource usage="fer sure">blah blah blah</typeOfResource></mods>', false)
        expect(@mods_rec.typeOfResource.usage).to eq(['fer sure'])
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
        expect(@mods_rec.send(elname.to_sym).map { |e| e.text }).to eq(["hi"])
      }
    end

    it "should return an array of strings when there are multiple occurrences of simple top level elements" do
      expect(@mods_rec.from_str(@mods_el_w_ns + '<note>hi</note><note>hello</note></mods>').note.map { |e| e.text }).to eq(["hi", "hello"])
    end

    context "<abstract> child element" do
      it ".abstract.displayLabel should be an accessor for displayLabel attribute on abstract element: <abstract displayLabel='foo'>" do
        @mods_rec.from_str(@mods_el_w_ns + '<abstract displayLabel="Summary">blah blah blah</abstract></mods>')
        expect(@mods_rec.abstract.displayLabel).to eq(['Summary'])
      end
      it ".abstract.type_at should be an accessor for type attribute on abstract element: <abstract type='foo'>" do
        @mods_rec.from_str(@mods_el_w_ns + '<abstract type="Scope and Contents note">blah blah blah</abstract></mods>')
        expect(@mods_rec.abstract.type_at).to eq(['Scope and Contents note'])
      end
    end

    context "<accessCondition> child element" do
      before(:all) do
        @acc_cond = @mods_rec.from_str(@mods_el_w_ns + '<accessCondition displayLabel="meh" type="useAndReproduction">blah blah blah</accessCondition></mods>').accessCondition
        @acc_cond2 = @mods_rec.from_str(@mods_el_w_ns + '<accessCondition type="useAndReproduction">All rights reserved.</accessCondition></mods>').accessCondition
      end
      it ".accessCondition.displayLabel should be an accessor for displayLabel attribute on accessCondition element: <accessCondition displayLabel='foo'>" do
        expect(@acc_cond.displayLabel).to eq(['meh'])
      end
      it ".accessCondition.type_at should be an accessor for type attribute on accessCondition element: <accessCondition type='foo'>" do
        [@acc_cond, @acc_cond2].each { |ac| expect(ac.type_at).to eq(['useAndReproduction']) }
      end
    end

    context "<classification> child element" do
      before(:all) do
        @class1 = @mods_rec.from_str(@mods_el_w_ns + '<classification authority="ddc" edition="11">683</classification></mods>').classification
        @class2 = @mods_rec.from_str(@mods_el_w_ns + '<classification authority="lcc">JK609.M2</classification></mods>').classification
      end
      it ".classification.authority should be an accessor for authority attribute on classification element: <classification authority='foo'>" do
        expect(@class1.authority).to eq(['ddc'])
        expect(@class2.authority).to eq(['lcc'])
      end
      it ".classification.edition should be an accessor for edition attribute on classification element: <classification edition='foo'>" do
        expect(@class1.edition).to eq(['11'])
      end
      it "should recognize all authority attributes" do
        Mods::AUTHORITY_ATTRIBS.each { |a|
          @mods_rec.from_str(@mods_el_w_ns + "<classification #{a}='attr_val'>zzz</classification></mods>")
          expect(@mods_rec.classification.send(a.to_sym)).to eq(['attr_val'])
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
        expect(@mods_rec.extension.displayLabel).to eq(['something'])
      end
    end

    context "<genre> child element" do
      it ".genre.displayLabel should be an accessor for displayLabel attribute on genre element: <genre displayLabel='foo'>" do
        @mods_rec.from_str(@mods_el_w_ns + '<genre displayLabel="something">blah blah blah</genre></mods>')
        expect(@mods_rec.genre.displayLabel).to eq(['something'])
      end
      it ".genre.type_at should be an accessor for type attribute on genre element: <genre type='foo'>" do
        @mods_rec.from_str(@mods_el_w_ns + '<genre type="maybe">blah blah blah</genre></mods>')
        expect(@mods_rec.genre.type_at).to eq(['maybe'])
      end
      it ".genre.usage should be an accessor for usage attribute on genre element: <genre usage='foo'>" do
        @mods_rec.from_str(@mods_el_w_ns + '<genre usage="fer sure">blah blah blah</genre></mods>')
        expect(@mods_rec.genre.usage).to eq(['fer sure'])
      end
      it "should recognize all authority attributes" do
        Mods::AUTHORITY_ATTRIBS.each { |a|
          @mods_rec.from_str(@mods_el_w_ns + "<genre #{a}='attr_val'>zzz</genre></mods>")
          expect(@mods_rec.genre.send(a.to_sym)).to eq(['attr_val'])
        }
      end
    end

    context "<identifier> child element" do
      before(:all) do
        @id = @mods_rec.from_str(@mods_el_w_ns + '<identifier displayLabel="book_number" type="local">70</identifier></mods>').identifier
      end
      it ".identifier.displayLabel should be an accessor for displayLabel attribute on identifier element: <identifier displayLabel='foo'>" do
        expect(@id.displayLabel).to eq(['book_number'])
      end
      it ".identifier.invalid should be an accessor for invalid attribute on identifier element: <identifier invalid='foo'>" do
        @mods_rec.from_str(@mods_el_w_ns + '<identifier type="isbn" invalid="yes">0877780116</identifier></mods>')
        expect(@mods_rec.identifier.invalid).to eq(['yes'])
      end
      it ".identifier.type_at should be an accessor for type attribute on identifier element: <identifier type='foo'>" do
        expect(@id.type_at).to eq(['local'])
      end
    end

    context "<note> child element" do
      it ".note.displayLabel should be an accessor for displayLabel attribute on note element: <note displayLabel='foo'>" do
        @mods_rec.from_str(@mods_el_w_ns + '<note displayLabel="state_note">blah</note></mods>')
        expect(@mods_rec.note.displayLabel).to eq(['state_note'])
      end
      it ".note.id_at should be an accessor for ID attribute on note element: <note ID='foo'>" do
        @mods_rec.from_str(@mods_el_w_ns + '<note ID="foo">blah blah blah</note></mods>')
        expect(@mods_rec.note.id_at).to eq(['foo'])
      end
      it ".note.type_at should be an accessor for type attribute on note element: <note type='foo'>" do
        @mods_rec.from_str(@mods_el_w_ns + '<note type="content">blah</note></mods>')
        expect(@mods_rec.note.type_at).to eq(['content'])
      end
    end

    context "<tableOfContents> child element" do
      it ".tableOfContents.displayLabel should be an accessor for displayLabel attribute on tableOfContents element: <tableOfContents displayLabel='foo'>" do
        @mods_rec.from_str(@mods_el_w_ns + '<tableOfContents displayLabel="Chapters included in book">blah blah</tableOfContents></mods>')
        expect(@mods_rec.tableOfContents.displayLabel).to eq(['Chapters included in book'])
      end
      it ".tableOfContents.shareable should be an accessor for shareable attribute on tableOfContents element: <tableOfContents shareable='foo'>" do
        @mods_rec.from_str(@mods_el_w_ns + '<tableOfContents shareable="no">blah blah blah</tableOfContents></mods>')
        expect(@mods_rec.tableOfContents.shareable).to eq(['no'])
      end
      it ".tableOfContents.type_at should be an accessor for type attribute on tableOfContents element: <tableOfContents type='foo'>" do
        @mods_rec.from_str(@mods_el_w_ns + '<tableOfContents type="partial contents">blah blah</tableOfContents></mods>')
        expect(@mods_rec.tableOfContents.type_at).to eq(['partial contents'])
      end
    end

    context "<targetAudience> child element" do
      it ".targetAudience.displayLabel should be an accessor for displayLabel attribute on targetAudience element: <targetAudience displayLabel='foo'>" do
        @mods_rec.from_str(@mods_el_w_ns + '<targetAudience displayLabel="ta da">blah blah</targetAudience></mods>')
        expect(@mods_rec.targetAudience.displayLabel).to eq(['ta da'])
      end
      it "should recognize all authority attributes" do
        Mods::AUTHORITY_ATTRIBS.each { |a|
          @mods_rec.from_str(@mods_el_w_ns + "<targetAudience #{a}='attr_val'>zzz</targetAudience></mods>")
          expect(@mods_rec.targetAudience.send(a.to_sym)).to eq(['attr_val'])
        }
      end
    end

    context "<typeOfResource> child element" do
      it ".typeOfResource.collection should be an accessor for collection attribute on typeOfResource element: <typeOfResource collection='foo'>" do
        @mods_rec.from_str(@mods_el_w_ns + '<typeOfResource collection="yes">blah blah blah</typeOfResource></mods>')
        expect(@mods_rec.typeOfResource.collection).to eq(['yes'])
      end
      it ".typeOfResource.displayLabel should be an accessor for displayLabel attribute on typeOfResource element: <typeOfResource displayLabel='foo'>" do
        @mods_rec.from_str(@mods_el_w_ns + '<typeOfResource displayLabel="Summary">blah blah blah</typeOfResource></mods>')
        expect(@mods_rec.typeOfResource.displayLabel).to eq(['Summary'])
      end
      it ".typeOfResource.manuscript should be an accessor for manuscript attribute on typeOfResource element: <typeOfResource manuscript='foo'>" do
        @mods_rec.from_str(@mods_el_w_ns + '<typeOfResource manuscript="yes">blah blah blah</typeOfResource></mods>')
        expect(@mods_rec.typeOfResource.manuscript).to eq(['yes'])
      end
      it ".typeOfResource.usage should be an accessor for usage attribute on typeOfResource element: <typeOfResource usage='foo'>" do
        @mods_rec.from_str(@mods_el_w_ns + '<typeOfResource usage="fer sure">blah blah blah</typeOfResource></mods>')
        expect(@mods_rec.typeOfResource.usage).to eq(['fer sure'])
      end
    end

  end # parsing with namespaces


end
