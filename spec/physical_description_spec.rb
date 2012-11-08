require 'spec_helper'

describe "Mods <physicalDescription> Element" do
  before(:all) do
    @mods_rec = Mods::Record.new
    @extent_only = '<mods><physicalDescription><extent>extent</extent></physicalDescription></mods>'
    @form_and_extent = '<mods><physicalDescription>
                           <form authority="smd">map</form>
                           <form type="material">foo</form>
                           <extent>1 map ; 22 x 18 cm.</extent>
                        </physicalDescription></mods>'
    @forms_and_notes = '<mods><physicalDescription>
                          <form authority="aat">Graphics</form>
                          <form>plain form</form>
                          <note displayLabel="Dimensions">dimension text</note>
                          <note displayLabel="Condition">condition text</note>
                        </physicalDescription></mods>'
    @digital = '<mods><physicalDescription>
                    <reformattingQuality>preservation</reformattingQuality>
                    <internetMediaType>image/jp2</internetMediaType>
                    <digitalOrigin>reformatted digital</digitalOrigin>
                </physicalDescription></mods>'
  end

  context "basic physical_description terminology pieces" do
    before(:all) do
      @mods_rec.from_str(@form_and_extent)
    end
    
    it "extent child element" do
      @mods_rec.from_str(@extent_only)
      @mods_rec.physical_description.extent.map { |n| n.text }.should == ["extent"]
    end

    context "note child element" do
      before(:all) do
        @mods_rec.from_str(@forms_and_notes)
      end
      it "should understand note element" do
        @mods_rec.physical_description.note.map { |n| n.text }.should == ["dimension text", "condition text"]
      end
      it "should understand displayLabel attribute on note element" do
        @mods_rec.physical_description.note.displayLabel.should == ["Dimensions", "Condition"]
      end
    end

    context "form child element" do
      before(:all) do
        @mods_rec.from_str(@form_and_extent)
      end
      it "should understand form element" do
        @mods_rec.physical_description.form.map { |n| n.text }.should == ["map", "foo"]
      end
      it "should understand authority attribute on form element" do
        @mods_rec.physical_description.form.authority.should == ["smd"]
      end
      it "should understand type attribute on form element" do
        @mods_rec.physical_description.form.type_at.should == ["material"]
      end
    end

    context "digital materials" do
      before(:all) do
        @mods_rec.from_str(@digital)
      end
      it "should understand reformattingQuality child element" do
        @mods_rec.physical_description.reformattingQuality.map { |n| n.text }.should == ["preservation"]
      end
      it "should understand digitalOrigin child element" do
        @mods_rec.physical_description.digitalOrigin.map { |n| n.text }.should == ["reformatted digital"]
      end
      it "should understand internetMediaType child element" do
        @mods_rec.physical_description.internetMediaType.map { |n| n.text }.should == ["image/jp2"]
      end
    end
  
  end # basic terminology pieces
  
end