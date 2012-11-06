# encoding: utf-8
require 'spec_helper'

describe "Mods Name" do
  
  it "should recognize subelements" do
    Mods::Name::SUBELEMENTS.each { |e|
      @mods_rec.from_str("<mods><name><#{e}>oofda</#{e}></name></mods>")
      @mods_rec.name.send(e).text.should == 'oofda'
    }
  end

  it "should recognize attributes on name node" do
    Mods::Name::ATTRIBUTES.each { |attrb|  
      @mods.from_str("<mods><name #{attrb}='hello'><displayForm>q</displayForm></name></mods>")
      @mods.name.send(attrb).should == 'hello'
    }
  end
  
  before(:all) do
    @mods_rec = Mods::Record.new
    @corp_name = 'ABC corp'
    @mods_w_corp_name = "<mods><name type='corporate'><namePart>#{@corp_name}</namePart></name></mods>"
    @mods_w_corp_name_role = "<mods><name type='corporate'><namePart>#{@corp_name}</namePart>
      <role><roleTerm type='text'>lithographer</roleTerm></role></name></mods>"
    @pers_name = 'Crusty'
    @mods_w_pers_name = "<mods><name type='personal'><namePart>#{@pers_name}</namePart></name></mods>"
    @pers_role = 'creator'
    @mods_w_pers_name_role = "<mods><name type='personal'><namePart>#{@pers_name}</namePart>
      <role><roleTerm authority='marcrelator' type='text'>#{@pers_role}</roleTerm><role></name></mods>"
    @mods_w_both = "<mods>
      <name type='corporate'><namePart>#{@corp_name}</namePart></name>
      <name type='personal'><namePart>#{@pers_name}</namePart></name></mods>"

      s = '<mods:name authority="local" type="personal">
        <mods:role>
          <mods:roleTerm authority="marcrelator" type="text">creator</mods:roleTerm>
        </mods:role>
        <mods:namePart>Gravé par Denise Macquart.</mods:namePart>
      </mods:name>
      '
      s = '<mods:name authority="local" type="personal">
        <mods:namePart>Buffier, Claude</mods:namePart>
      </mods:name>
      '
  end
  
  context "personal_author" do
    
    it "should recognize subelements" do
      Mods::Name::SUBELEMENTS.each { |e|
        @mods_rec.from_str("<mods><name><#{e}>oofda</#{e}></name></mods>")
        @mods_rec.personal_name.send(e).text.should == 'oofda'
      }
    end
    it "should include name elements with type attr = personal" do
      @mods_rec.from_str(@mods_w_pers_name)
      @mods_rec.personal_name.namePart.text.should == @pers_name
      @mods_rec.from_str(@mods_w_both).personal_name.namePart.text.should == @pers_name
    end
    it "should not include name elements with type attr != personal" do
      @mods_rec.from_str(@mods_w_corp_name)
      @mods_rec.personal_name.namePart.text.should == ""
      @mods_rec.from_str(@mods_w_both).personal_name.namePart.text.should_not match(@corp_name)
    end
    
    context "personal_names convenience method" do
      before(:all) do
        @given_family = '<mods><name type="personal"><namePart type="given">Jorge Luis</namePart>
                                <namePart type="family">Borges</namePart></name></mods>'        
        @given_family_date = '<mods><name type="personal"><namePart type="given">Zaphod</namePart>
                                <namePart type="family">Beeblebrox</namePart>
                                <namePart type="date">1912-2362</namePart></name></mods>'
        @all_name_parts = '<mods><name type="personal"><namePart type="given">Given</namePart>
                                <namePart type="family">Family</namePart>
                                <namePart type="termsOfAddress">Mr.</namePart>
                                <namePart type="date">date</namePart></name></mods>'
        @family_only = '<mods><name type="personal"><namePart type="family">Family</namePart></name></mods>'
        @given_only = '<mods><name type="personal"><namePart type="given">Given</namePart></name></mods>'
      end

      it "should return an Array of Strings" do
        @mods_rec.from_str(@mods_w_pers_name)
        @mods_rec.personal_names.should == [@pers_name]
      end

      it "should not include the role text" do
        @mods_rec.from_str(@mods_w_pers_name_role)
        @mods_rec.personal_names.first.should_not match(@pers_role)
      end
      
      it "should prefer displayForm over namePart pieces" do
        display_form_and_name_parts = '<mods><name type="personal"><namePart type="given">Jorge Luis</namePart>
                                <namePart type="family">Borges</namePart>
                                <displayForm>display form</displayForm></name></mods>'        
        @mods_rec.from_str(display_form_and_name_parts)
        @mods_rec.personal_names.should include("display form")
      end

      it "should put the family namePart first" do
        @mods_rec.from_str(@given_family)
        @mods_rec.personal_names.first.should match(/^Borges/)
        @mods_rec.from_str(@given_family_date)
        @mods_rec.personal_names.first.should match(/^Beeblebrox/)
      end
      it "should not include date" do
        @mods_rec.from_str(@given_family_date)
        @mods_rec.personal_names.first.should_not match(/19/)
        @mods_rec.from_str(@all_name_parts)
        @mods_rec.personal_names.first.should_not match('date')
      end
      it "should include a comma when there is both a family and a given name" do
        @mods_rec.from_str(@all_name_parts)
        @mods_rec.personal_names.should include("Family, Given")
      end
      it "should include multiple words in a namePart" do
        @mods_rec.from_str(@given_family)
        @mods_rec.personal_names.should include("Borges, Jorge Luis")
      end
      it "should not include a comma when there is only a family or given name" do
        [@family_only, @given_only].each { |mods_str|  
          @mods_rec.from_str(mods_str)
          @mods_rec.personal_names.first.should_not match(/,/)
        }
      end
      it "should not include terms of address" do
        @mods_rec.from_str(@all_name_parts)
        @mods_rec.personal_names.first.should_not match(/Mr./)
      end      
    end # personal_names convenience method
  end # personal_name
  
  context "sort_author" do
    
  end
  
  context "corporate_author" do
    it "should include name elements with type attr = corporate" do
      @mods_rec.from_str(@mods_w_corp_name)
      @mods_rec.corporate_name.namePart.text.should == @corp_name
      @mods_rec.from_str(@mods_w_both).corporate_name.namePart.text.should == @corp_name
    end
    it "should not include name elements with type attr != corporate" do
      @mods_rec.from_str(@mods_w_pers_name)
      @mods_rec.corporate_name.namePart.text.should == ""
      @mods_rec.from_str(@mods_w_both).corporate_name.namePart.text.should_not match(@pers_name)
    end
    it "should not include the role text" do
      @mods_rec.from_str(@mods_w_corp_name_role)      
      @mods_rec.corporate_name.namePart.text.should == @corp_name
      pending "need to work on this"
    end
    it "convenience method corporate_names in Mods::Record should return an Array of Strings" do
      pending "to be implemented"
      @mods_rec.from_str('<mods><titleInfo><title>Jerk</title><nonSort>The</nonSort></titleInfo><titleInfo><title>Joke</title></titleInfo></mods>')
      @mods_rec.corporate_names.should == ["The Jerk", "Joke"]
    end
  end  
  
  context "namePart subelement" do

    it "should recognize type attribute on namePart element" do
      Mods::Name::NAME_PART_TYPES.each { |t|  
        @mods.from_str("<mods><name><namePart type='#{t}'>hi</namePart></name></mods>")
        @mods.name.namePart.type.should == t
      }
    end

  end

  context "role subelement" do
    it "should work when there is no subelement" do
      pending "to be implemented"
    end
    it "should work when there is a roleTerm subelement" do
      pending "to be implemented"
    end
    it "should do something when there is some other illegal subelement" do
      pending "to be implemented"
    end
    it "should translate the marc relator code into text" do
      pending "to be implemented"
    end
  end
  
  context "value for mods.name" do
    it "should prefer displayForm subelement value to concat of namePart subelement values" do
      str =  '<mods><name><displayForm>Mr. Foo Bar</displayForm><namePart>a</namePart><namePart>b</namePart></name></mods>'
      @mods.from_str(str)
      @mods.name.displayForm.should == ["Mr. Foo Bar"]
      @mods.name.should == ["Mr. Foo Bar"]
    end
    it "should give concat of nameParts if there is no displayForm subelement" do
      @mods.from_str('<mods><name><namePart>a</namePart><namePart>b</namePart></name></mods>')
      @mods.name.should == ["a b"]
    end
    it "should order the namePart elements according to their type attribute, if present" do
      pending "to be implemented"
    end
    it "should combine any and all subelements into a useful string" do
      pending "to be implemented"
      @mods.name.should == ["first name pieces", "second name pieces"]
    end
    
  end
  
  
end