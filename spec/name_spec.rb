require 'spec_helper'

describe "Mods Name" do
  
  before(:all) do
    @mods_rec = Mods::Record.new
    @corp_name = 'ABC corp'
    @mods_w_corp_name = "<mods><name type='corporate'><namePart>#{@corp_name}</namePart></name></mods>"
    @mods_w_corp_name_role = "<mods><name type='corporate'><namePart>#{@corp_name}</namePart>
      <role><roleTerm type='text'>lithographer</roleTerm></role></name></mods>"
    @pers_name = 'Crusty'
    @mods_w_pers_name = "<mods><name type='personal'><namePart>#{@pers_name}</namePart></name></mods>"
    @mods_w_both = "<mods>
      <name type='corporate'><namePart>#{@corp_name}</namePart></name>
      <name type='personal'><namePart>#{@pers_name}</namePart></name></mods>"
  end
  
  context "personal name" do
    before(:all) do
      @pers_role = 'creator'
      @mods_w_pers_name_role = "<mods><name type='personal'><namePart>#{@pers_name}</namePart>
        <role><roleTerm authority='marcrelator' type='text'>#{@pers_role}</roleTerm><role></name></mods>"
      @mods_w_pers_name_role_code = '<mods><name type="personal"><namePart type="given">John</namePart>
          	<namePart type="family">Huston</namePart>
          	<role>
          	  	<roleTerm type="code" authority="marcrelator">drt</roleTerm>
          	</role>
        </name></mods>'
      s = '<mods><name authority="local" type="personal"><namePart>Buffier, Claude</namePart></name></mods>'
    end
    
    it "should recognize subelements" do
      Mods::Name::SUBELEMENTS.reject{|e| e == "role"}.each { |e|
        @mods_rec.from_str("<mods><name type='personal'><#{e}>oofda</#{e}></name></mods>")
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
    
    context "roles" do
      it "should be possible to access a personal_name role easily" do
        @mods_rec.from_str(@mods_w_pers_name_role)
        @mods_rec.personal_name.role.text.should include(@pers_role)
      end

      it "should get role type" do
        @mods_rec.from_str(@mods_w_pers_name_role)
        @mods_rec.personal_name.role.type.should == ["text"]
        @mods_rec.from_str(@mods_w_pers_name_role_code)
        @mods_rec.personal_name.role.type.should == ["code"]
      end
      
      it "should get role authority" do
        @mods_rec.from_str(@mods_w_pers_name_role)
        @mods_rec.personal_name.role.authority.should == ["marcrelator"]
      end
      
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
  end # personal name
  
  context "sort_author" do
    it "should do something" do
      pending "sort_author to be implemented"
    end
  end
  
  context "corporate name" do
    before(:all) do
      @corp_role = 'lithographer'
      @mods_w_corp_name_role = "<mods><name type='corporate'><namePart>#{@corp_name}</namePart>
        <role><roleTerm type='text'>#{@corp_role}</roleTerm></role></name></mods>"
      s = '<mods><name type="corporate"><namePart>Sherman &amp; Smith</namePart>
           <role><roleTerm authority="marcrelator" type="text">creator</roleTerm></role></name></mods>'
    end
    
    it "should recognize subelements" do
      Mods::Name::SUBELEMENTS.reject{|e| e == "role"}.each { |e|
        @mods_rec.from_str("<mods><name type='corporate'><#{e}>oofda</#{e}></name></mods>")
        @mods_rec.corporate_name.send(e).text.should == 'oofda'
      }
    end
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

    context "corporate_names convenience method" do
      it "should return an Array of Strings" do
        @mods_rec.from_str(@mods_w_corp_name)
        @mods_rec.corporate_names.should == [@corp_name]
      end

      it "should not include the role text" do
        @mods_rec.from_str(@mods_w_corp_name_role)      
        @mods_rec.corporate_names.first.should_not match(@corp_role)
      end
      
      it "should prefer displayForm over namePart pieces" do
        display_form_and_name_parts = '<mods><name type="corporate"><namePart>Food, Inc.</namePart>
                                <displayForm>display form</displayForm></name></mods>'        
        @mods_rec.from_str(display_form_and_name_parts)
        @mods_rec.corporate_names.should include("display form")
      end
    end # corporate_names convenience method
  end # corporate name
  
  context "(plain) name element access" do

    it "should recognize subelements" do
      Mods::Name::SUBELEMENTS.reject{|e| e == "role"}.each { |e|
        @mods_rec.from_str("<mods><name><#{e}>oofda</#{e}></name></mods>")
        @mods_rec.plain_name.send(e).text.should == 'oofda'
      }
    end

    it "should recognize attributes on name node" do
      Mods::Name::ATTRIBUTES.each { |attrb| 
        @mods_rec.from_str("<mods><name #{attrb}='hello'><displayForm>q</displayForm></name></mods>")
        @mods_rec.plain_name.send(attrb).should == 'hello'
      }
    end
    
    context "namePart subelement" do
      it "should recognize type attribute on namePart element" do
        Mods::Name::NAME_PART_TYPES.each { |t|  
          @mods_rec.from_str("<mods><name><namePart type='#{t}'>hi</namePart></name></mods>")
          @mods_rec.plain_name.namePart.type.text.should == t
        }
      end
    end
    
    context "role subelement" do
      it "should do something" do
        pending "to be implemented"
      end
    end

  end # plain name
  
  it "should be able to translate the marc relator code into text" do
    MARC_RELATOR['drt'].should == "Director"
  end
  
end