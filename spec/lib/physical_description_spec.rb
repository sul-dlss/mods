require 'spec_helper'

describe "Mods <physicalDescription> Element" do
  it "extent child element" do
    record = mods_record("<physicalDescription><extent>extent</extent></physicalDescription>")
    expect(record.physical_description.extent.map(&:text)).to eq(["extent"])
  end

  context "note child element" do
    subject(:note) do
      mods_record(<<-XML).physical_description.note
        <physicalDescription>
          <form authority='aat'>Graphics</form>
          <form>plain form</form>
          <note displayLabel='Dimensions'>dimension text</note>
          <note displayLabel='Condition'>condition text</note>
        </physicalDescription>
      XML
    end
    it "should understand note element" do
      expect(note.map(&:text)).to eq(["dimension text", "condition text"])
    end
    it "should understand displayLabel attribute on note element" do
      expect(note.displayLabel).to eq(["Dimensions", "Condition"])
    end
  end

  context "form child element" do
    subject(:physical_description) do
      mods_record(<<-XML).physical_description
        <physicalDescription>
          <form authority='smd'>map</form>
          <form type='material'>foo</form>
          <extent>1 map ; 22 x 18 cm.</extent>
        </physicalDescription>
      XML
    end

    it "should understand form element" do
      expect(physical_description.form.map(&:text)).to eq(["map", "foo"])
    end
    it "should understand authority attribute on form element" do
      expect(physical_description.form.authority).to eq(["smd"])
    end
    it "should understand type attribute on form element" do
      expect(physical_description.form.type_at).to eq(["material"])
    end
  end

  context "digital materials" do
    subject(:physical_description) do
      mods_record(<<-XML).physical_description
        <physicalDescription>
          <reformattingQuality>preservation</reformattingQuality>
          <internetMediaType>image/jp2</internetMediaType>
          <digitalOrigin>reformatted digital</digitalOrigin>
        </physicalDescription>
      XML
    end

    it "should understand reformattingQuality child element" do
      expect(physical_description.reformattingQuality.map(&:text)).to eq(["preservation"])
    end
    it "should understand digitalOrigin child element" do
      expect(physical_description.digitalOrigin.map(&:text)).to eq(["reformatted digital"])
    end
    it "should understand internetMediaType child element" do
      expect(physical_description.internetMediaType.map(&:text)).to eq(["image/jp2"])
    end
  end

end
