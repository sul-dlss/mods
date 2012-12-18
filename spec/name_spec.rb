require 'spec_helper'

describe "Mods <name> Element" do
  
  before(:all) do
    @mods_rec = Mods::Record.new
    @ns_decl = "xmlns='#{Mods::MODS_NS}'"
    
    @corp_name = 'ABC corp'
    @mods_w_corp_name_ns = "<mods #{@ns_decl}><name type='corporate'><namePart>#{@corp_name}</namePart></name></mods>"
    @mods_w_corp_name = @mods_w_corp_name_ns.sub(" #{@ns_decl}", '')
    @mods_w_corp_name_role_ns = "<mods #{@ns_decl}><name type='corporate'><namePart>#{@corp_name}</namePart>
      <role><roleTerm type='text'>lithographer</roleTerm></role></name></mods>"
    @mods_w_corp_name_role = @mods_w_corp_name_role_ns.sub(" #{@ns_decl}", '')

    @pers_name = 'Crusty'
    @mods_w_pers_name_ns = "<mods #{@ns_decl}><name type='personal'><namePart>#{@pers_name}</namePart></name></mods>"
    @mods_w_pers_name = @mods_w_pers_name_ns.sub(" #{@ns_decl}", '')
    @mods_w_both_ns = "<mods #{@ns_decl}>
      <name type='corporate'><namePart>#{@corp_name}</namePart></name>
      <name type='personal'><namePart>#{@pers_name}</namePart></name></mods>"
    @mods_w_both = @mods_w_both_ns.sub(" #{@ns_decl}", '')

    @pers_role = 'creator'
    @mods_w_pers_name_role_ns = "<mods #{@ns_decl}><name type='personal'><namePart>#{@pers_name}</namePart>
      <role><roleTerm authority='marcrelator' type='text'>#{@pers_role}</roleTerm><role></name></mods>"
    @mods_w_pers_name_role = @mods_w_pers_name_role_ns.sub(" #{@ns_decl}", '')
    @mods_w_pers_name_role_code_ns = "<mods #{@ns_decl}><name type='personal'><namePart type='given'>John</namePart>
        	<namePart type='family'>Huston</namePart>
        	<role>
        	  	<roleTerm type='code' authority='marcrelator'>drt</roleTerm>
        	</role>
      </name></mods>"
    @mods_w_pers_name_role_code = @mods_w_pers_name_role_code_ns.sub(" #{@ns_decl}", '')
  end
  
  context "personal name" do
    
    context "WITH namespaces" do
      it "should recognize child elements" do
        Mods::Name::CHILD_ELEMENTS.reject{|e| e == "role"}.each { |e|
          @mods_rec.from_str("<mods #{@ns_decl}><name type='personal'><#{e}>oofda</#{e}></name></mods>")
          if e == 'description'
            @mods_rec.personal_name.description_el.text.should == 'oofda'
          else
            @mods_rec.personal_name.send(e).text.should == 'oofda'
          end
        }
      end
      it "should include name elements with type attr = personal" do
        @mods_rec.from_str(@mods_w_pers_name_ns)
        @mods_rec.personal_name.namePart.text.should == @pers_name
        @mods_rec.from_str(@mods_w_both_ns).personal_name.namePart.text.should == @pers_name
      end
      it "should not include name elements with type attr != personal" do
        @mods_rec.from_str(@mods_w_corp_name_ns)
        @mods_rec.personal_name.namePart.text.should == ""
        @mods_rec.from_str(@mods_w_both_ns).personal_name.namePart.text.should_not match(@corp_name)
      end

      context "roles" do
        it "should be possible to access a personal_name role easily" do
          @mods_rec.from_str(@mods_w_pers_name_role_ns)
          @mods_rec.personal_name.role.roleTerm.text.should include(@pers_role)
        end
        it "should get role type" do
          @mods_rec.from_str(@mods_w_pers_name_role_ns)
          @mods_rec.personal_name.role.roleTerm.type_at.should == ["text"]
          @mods_rec.from_str(@mods_w_pers_name_role_code_ns)
          @mods_rec.personal_name.role.roleTerm.type_at.should == ["code"]
        end
        it "should get role authority" do
          @mods_rec.from_str(@mods_w_pers_name_role_ns)
          @mods_rec.personal_name.role.roleTerm.authority.should == ["marcrelator"]
        end
      end # roles
    end # WITH namespaces
    
    context "WITHOUT namespaces" do
      it "should recognize child elements" do
        Mods::Name::CHILD_ELEMENTS.reject{|e| e == "role"}.each { |e|
          @mods_rec.from_str("<mods><name type='personal'><#{e}>oofda</#{e}></name></mods>", false)
          if e == 'description'
            @mods_rec.personal_name.description_el.text.should == 'oofda'
          else
            @mods_rec.personal_name.send(e).text.should == 'oofda'
          end
        }
      end
      it "should include name elements with type attr = personal" do
        @mods_rec.from_str(@mods_w_pers_name, false)
        @mods_rec.personal_name.namePart.text.should == @pers_name
        @mods_rec.from_str(@mods_w_both, false).personal_name.namePart.text.should == @pers_name
      end
      it "should not include name elements with type attr != personal" do
        @mods_rec.from_str(@mods_w_corp_name, false)
        @mods_rec.personal_name.namePart.text.should == ""
        @mods_rec.from_str(@mods_w_both, false).personal_name.namePart.text.should_not match(@corp_name)
      end

      context "roles" do
        it "should be possible to access a personal_name role easily" do
          @mods_rec.from_str(@mods_w_pers_name_role, false)
          @mods_rec.personal_name.role.text.should include(@pers_role)
        end
        it "should get role type" do
          @mods_rec.from_str(@mods_w_pers_name_role, false)
          @mods_rec.personal_name.role.roleTerm.type_at.should == ["text"]
          @mods_rec.from_str(@mods_w_pers_name_role_code, false)
          @mods_rec.personal_name.role.roleTerm.type_at.should == ["code"]
        end
        it "should get role authority" do
          @mods_rec.from_str(@mods_w_pers_name_role, false)
          @mods_rec.personal_name.role.roleTerm.authority.should == ["marcrelator"]
        end
      end # roles    
    end # WITHOUT namespaces

    # note that Mods::Record.personal_names tests are in record_spec
    
  end # personal name
  
  context "sort_author" do
    it "should do something" do
      pending "sort_author to be implemented (choose creator if present ... )"
    end
  end
  
  context "corporate name" do    
    context "WITH namespaces" do
      it "should recognize child elements" do
        Mods::Name::CHILD_ELEMENTS.reject{|e| e == "role" }.each { |e|
          @mods_rec.from_str("<mods #{@ns_decl}><name type='corporate'><#{e}>oofda</#{e}></name></mods>")
          if e == 'description'
            @mods_rec.corporate_name.description_el.text.should == 'oofda'
          else
            @mods_rec.corporate_name.send(e).text.should == 'oofda'
          end
        }
      end
      it "should include name elements with type attr = corporate" do
        @mods_rec.from_str(@mods_w_corp_name_ns)
        @mods_rec.corporate_name.namePart.text.should == @corp_name
        @mods_rec.from_str(@mods_w_both_ns).corporate_name.namePart.text.should == @corp_name
      end
      it "should not include name elements with type attr != corporate" do
        @mods_rec.from_str(@mods_w_pers_name_ns)
        @mods_rec.corporate_name.namePart.text.should == ""
        @mods_rec.from_str(@mods_w_both_ns).corporate_name.namePart.text.should_not match(@pers_name)
      end
    end # WITH namespaces
    context "WITHOUT namespaces" do
      it "should recognize child elements" do
        Mods::Name::CHILD_ELEMENTS.reject{|e| e == "role" }.each { |e|
          @mods_rec.from_str("<mods><name type='corporate'><#{e}>oofda</#{e}></name></mods>", false)
          if e == 'description'
            @mods_rec.corporate_name.description_el.text.should == 'oofda'
          else
            @mods_rec.corporate_name.send(e).text.should == 'oofda'
          end
        }
      end
      it "should include name elements with type attr = corporate" do
        @mods_rec.from_str(@mods_w_corp_name, false)
        @mods_rec.corporate_name.namePart.text.should == @corp_name
        @mods_rec.from_str(@mods_w_both, false).corporate_name.namePart.text.should == @corp_name
      end
      it "should not include name elements with type attr != corporate" do
        @mods_rec.from_str(@mods_w_pers_name, false)
        @mods_rec.corporate_name.namePart.text.should == ""
        @mods_rec.from_str(@mods_w_both, false).corporate_name.namePart.text.should_not match(@pers_name)
      end
    end # WITHOUT namespaces
    
    # note that Mods::Record.corporate_names tests are in record_spec

  end # corporate name
  
  
  context "(plain) <name> element terminology pieces" do
    
    context "WITH namespaces" do
      it "should recognize child elements" do
        Mods::Name::CHILD_ELEMENTS.reject{|e| e == "role"}.each { |e|
          @mods_rec.from_str("<mods #{@ns_decl}><name><#{e}>oofda</#{e}></name></mods>")
          if e == 'description'
            @mods_rec.plain_name.description_el.text.should == 'oofda'
          else
            @mods_rec.plain_name.send(e).text.should == 'oofda'
          end
        }
      end
      it "should recognize attributes on name node" do
        Mods::Name::ATTRIBUTES.each { |attrb| 
          @mods_rec.from_str("<mods #{@ns_decl}><name #{attrb}='hello'><displayForm>q</displayForm></name></mods>")
          if attrb != 'type'
            @mods_rec.plain_name.send(attrb).should == ['hello']
          else
            @mods_rec.plain_name.type_at.should == ['hello']
          end
        }
      end
      context "namePart child element" do
        it "should recognize type attribute on namePart element" do
          Mods::Name::NAME_PART_TYPES.each { |t|  
            @mods_rec.from_str("<mods #{@ns_decl}><name><namePart type='#{t}'>hi</namePart></name></mods>")
            @mods_rec.plain_name.namePart.type_at.should == [t]
          }
        end
      end
      context "role child element" do
        it "should get role type" do
          @mods_rec.from_str(@mods_w_pers_name_role_ns)
          @mods_rec.plain_name.role.roleTerm.type_at.should == ["text"]
          @mods_rec.from_str(@mods_w_pers_name_role_code_ns)
          @mods_rec.plain_name.role.roleTerm.type_at.should == ["code"]
        end
        it "should get role authority" do
          @mods_rec.from_str(@mods_w_pers_name_role_ns)
          @mods_rec.plain_name.role.roleTerm.authority.should == ["marcrelator"]
        end
      end
      
    end # context WITH namespaces

    context "WITHOUT namespaces" do
      it "should recognize child elements" do
        Mods::Name::CHILD_ELEMENTS.reject{|e| e == "role"}.each { |e|
          @mods_rec.from_str("<mods><name><#{e}>oofda</#{e}></name></mods>", false)
          if e == 'description'
            @mods_rec.plain_name.description_el.text.should == 'oofda'
          else
            @mods_rec.plain_name.send(e).text.should == 'oofda'
          end
        }
      end
      it "should recognize attributes on name node" do
        Mods::Name::ATTRIBUTES.each { |attrb| 
          @mods_rec.from_str("<mods><name #{attrb}='hello'><displayForm>q</displayForm></name></mods>", false)
          if attrb != 'type'
            @mods_rec.plain_name.send(attrb).should == ['hello']
          else
            @mods_rec.plain_name.type_at.should == ['hello']
          end
        }
      end
      context "namePart child element" do
        it "should recognize type attribute on namePart element" do
          Mods::Name::NAME_PART_TYPES.each { |t|  
            @mods_rec.from_str("<mods><name><namePart type='#{t}'>hi</namePart></name></mods>", false)
            @mods_rec.plain_name.namePart.type_at.should == [t]
          }
        end
      end
      context "role child element" do
        it "should get role type" do
          @mods_rec.from_str(@mods_w_pers_name_role, false)
          @mods_rec.plain_name.role.roleTerm.type_at.should == ["text"]
          @mods_rec.from_str(@mods_w_pers_name_role_code, false)
          @mods_rec.plain_name.role.roleTerm.type_at.should == ["code"]
        end
        it "should get role authority" do
          @mods_rec.from_str(@mods_w_pers_name_role, false)
          @mods_rec.plain_name.role.roleTerm.authority.should == ["marcrelator"]
        end
      end
    end # context WITHOUT namespaces

  end # plain name

  
  it "should be able to translate the marc relator code into text" do
    MARC_RELATOR['drt'].should == "Director"
  end
  
  context "roles" do
    before(:all) do
      @xml_w_code = "<mods #{@ns_decl}><name><namePart>Alfred Hitchock</namePart>
                <role><roleTerm type='code' authority='marcrelator'>drt</roleTerm></role>
            </name></mods>"
      @xml_w_text = "<mods #{@ns_decl}><name><namePart>Sean Connery</namePart>
                <role><roleTerm type='text' authority='marcrelator'>Actor</roleTerm></role>
            </name></mods>"
      @xml_wo_authority = "<mods #{@ns_decl}><name><namePart>Exciting Prints</namePart>
                <role><roleTerm type='text'>lithographer</roleTerm></role>
            </name></mods>"
      @xml_w_both = "<mods #{@ns_decl}><name><namePart>anyone</namePart>
                <role>
                  <roleTerm type='text' authority='marcrelator'>CreatorFake</roleTerm>
                  <roleTerm type='code' authority='marcrelator'>cre</roleTerm>
                </role>
            </name></mods>"
      @xml_w_mult_roles = "<mods #{@ns_decl}><name><namePart>Fats Waller</namePart>
                <role><roleTerm type='text'>Creator</roleTerm>
                      <roleTerm type='code' authority='marcrelator'>cre</roleTerm></role>
                <role><roleTerm type='text'>Performer</roleTerm></role>
            </name></mods>"
    end

    context "convenience methods WITH namespaces" do
      before(:all) do
        @mods_w_code = Mods::Record.new.from_str(@xml_w_code)
        @mods_w_text = Mods::Record.new.from_str(@xml_w_text)
        @mods_wo_authority = Mods::Record.new.from_str(@xml_wo_authority)
        @mods_w_both = Mods::Record.new.from_str(@xml_w_both)
        @mods_mult_roles = Mods::Record.new.from_str(@xml_w_mult_roles)
      end  
      context "value" do
        it "should be the value of a text roleTerm" do
          @mods_w_text.plain_name.role.value.should == ["Actor"]
        end  
        it "should be the translation of the code if it is a marcrelator code and there is no text roleTerm" do
          @mods_w_code.plain_name.role.value.should == ["Director"]
        end
        it "should be the value of the text roleTerm if there are both a code and a text roleTerm" do
          @mods_w_both.plain_name.role.value.should == ["CreatorFake"]
        end
        it "should have 2 values if there are 2 role elements" do
          @mods_mult_roles.plain_name.role.value.should == ['Creator', 'Performer']
        end
      end
      context "authority" do
        it "should be empty if it is missing from xml" do
          @mods_wo_authority.plain_name.role.authority.size.should == 0
        end
        it "should be the value of the authority attribute on the roleTerm element" do
          @mods_w_code.plain_name.role.authority.should == ["marcrelator"]
          @mods_w_text.plain_name.role.authority.should == ["marcrelator"]
          @mods_w_both.plain_name.role.authority.should == ["marcrelator"]
        end
      end
      context "code" do
        it "should be empty if the roleTerm is not of type code" do
          @mods_w_text.plain_name.role.code.size.should == 0
          @mods_wo_authority.plain_name.role.code.size.should == 0
        end
        it "should be the value of the roleTerm element if element's type attribute is 'code'" do
          @mods_w_code.plain_name.role.code.should == ["drt"]
          @mods_w_both.plain_name.role.code.should == ["cre"]
        end
      end
      context "pertaining to a specific name" do
        before(:all) do
          @xml_w_role_text = "<mods #{@ns_decl}><name>
                        <namePart>Sean Connery</namePart>
                        <role><roleTerm type='text' authority='marcrelator'>Actor</roleTerm></role>
                      </name></mods>"
        end
        context "convenience methods WITH namespaces" do
          it "roles should be empty array when there is no role element" do
            @mods_rec.from_str(@mods_w_pers_name_ns)
            @mods_rec.personal_name.first.role.size.should == 0
          end
          it "object should have same number of roles as it has role nodes in xml" do
            @mods_mult_roles.plain_name.first.role.size.should == 2
          end
          context "name's roles should be correctly populated" do
            it "text attribute" do
              @mods_w_text.plain_name.role.value.should == ['Actor']
              @mods_rec.from_str(@mods_w_pers_name_role_code_ns)
              @mods_rec.personal_name.first.role.value.should == ['Director']
            end
            it "code attribute" do
              @mods_rec.from_str(@mods_w_pers_name_role_code_ns)
              @mods_rec.personal_name.first.role.code.should == ['drt']
            end
            it "authority attribute" do
              @mods_rec.from_str(@mods_w_corp_name_role_ns)
              @mods_rec.plain_name.role.authority.should == ['marcrelator']
            end
            it "multiple roles" do
              @mods_mult_roles.plain_name.first.role.value.should == ['Creator', 'Performer']
              @mods_mult_roles.plain_name.first.role.code.should == ['cre']
              @mods_mult_roles.plain_name.role.first.roleTerm.authority.first.should == 'marcrelator'
              @mods_mult_roles.plain_name.role.last.roleTerm.authority.size.should == 0
            end      
          end
        end
      end # pertaining to a specific name
    end # roles WITH namespaces
      
    context "convenience methods WITHOUT namespaces" do
      before(:all) do
        @mods_w_code = Mods::Record.new.from_str(@xml_w_code.sub(" #{@ns_decl}", ''), false)
        @mods_w_text = Mods::Record.new.from_str(@xml_w_text.sub(" #{@ns_decl}", ''), false)
        @mods_wo_authority = Mods::Record.new.from_str(@xml_wo_authority.sub(" #{@ns_decl}", ''), false)
        @mods_w_both = Mods::Record.new.from_str(@xml_w_both.sub(" #{@ns_decl}", ''), false)
        @mods_mult_roles = Mods::Record.new.from_str(@xml_w_mult_roles.sub(" #{@ns_decl}", ''), false)
      end
      context "value" do
        it "should be the value of a text roleTerm" do
          @mods_w_text.plain_name.role.value.should == ["Actor"]
        end  
        it "should be the translation of the code if it is a marcrelator code and there is no text roleTerm" do
          @mods_w_code.plain_name.role.value.should == ["Director"]
        end
        it "should be the value of the text roleTerm if there are both a code and a text roleTerm" do
          @mods_w_both.plain_name.role.value.should == ["CreatorFake"]
        end
      end
      context "authority" do
        it "should be empty if it is missing from xml" do
          @mods_wo_authority.plain_name.role.authority.size.should == 0
        end
        it "should be the value of the authority attribute on the roleTerm element" do
          @mods_w_code.plain_name.role.authority.should == ["marcrelator"]
          @mods_w_text.plain_name.role.authority.should == ["marcrelator"]
          @mods_w_both.plain_name.role.authority.should == ["marcrelator"]
        end
      end
      context "code" do
        it "should be empty if the roleTerm is not of type code" do
          @mods_w_text.plain_name.role.code.size.should == 0
          @mods_wo_authority.plain_name.role.code.size.should == 0
        end
        it "should be the value of the roleTerm element if element's type attribute is 'code'" do
          @mods_w_code.plain_name.role.code.should == ["drt"]
          @mods_w_both.plain_name.role.code.should == ["cre"]
        end
      end
    end # WITHOUT namespaces    
      
    
  end # roles
  
end