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

  describe "lang" do
    it "should have a lang attribute" do
      @mods_rec.from_str("<mods #{@ns_decl}><name type='personal'><namePart xml:lang='fr-FR' type='given'>Jean</namePart><namePart xml:lang='en-US' type='given'>John</namePart></name></mods>")
      expect(@mods_rec.personal_name.namePart.lang).to include "en-US", "fr-FR"
    end
  end
  
  context "personal name" do
    
    context "WITH namespaces" do
      it "should recognize child elements" do
        Mods::Name::CHILD_ELEMENTS.reject{|e| e == "role"}.each { |e|
          @mods_rec.from_str("<mods #{@ns_decl}><name type='personal'><#{e}>oofda</#{e}></name></mods>")
          if e == 'description'
            expect(@mods_rec.personal_name.description_el.text).to eq('oofda')
          else
            expect(@mods_rec.personal_name.send(e).text).to eq('oofda')
          end
        }
      end
      it "should include name elements with type attr = personal" do
        @mods_rec.from_str(@mods_w_pers_name_ns)
        expect(@mods_rec.personal_name.namePart.text).to eq(@pers_name)
        expect(@mods_rec.from_str(@mods_w_both_ns).personal_name.namePart.text).to eq(@pers_name)
      end
      it "should not include name elements with type attr != personal" do
        @mods_rec.from_str(@mods_w_corp_name_ns)
        expect(@mods_rec.personal_name.namePart.text).to eq("")
        expect(@mods_rec.from_str(@mods_w_both_ns).personal_name.namePart.text).not_to match(@corp_name)
      end

      context "roles" do
        it "should be possible to access a personal_name role easily" do
          @mods_rec.from_str(@mods_w_pers_name_role_ns)
          expect(@mods_rec.personal_name.role.roleTerm.text).to include(@pers_role)
        end
        it "should get role type" do
          @mods_rec.from_str(@mods_w_pers_name_role_ns)
          expect(@mods_rec.personal_name.role.roleTerm.type_at).to eq(["text"])
          @mods_rec.from_str(@mods_w_pers_name_role_code_ns)
          expect(@mods_rec.personal_name.role.roleTerm.type_at).to eq(["code"])
        end
        it "should get role authority" do
          @mods_rec.from_str(@mods_w_pers_name_role_ns)
          expect(@mods_rec.personal_name.role.roleTerm.authority).to eq(["marcrelator"])
        end
      end # roles
    end # WITH namespaces (personal name)
    
    context "WITHOUT namespaces" do
      it "should recognize child elements" do
        Mods::Name::CHILD_ELEMENTS.reject{|e| e == "role"}.each { |e|
          @mods_rec.from_str("<mods><name type='personal'><#{e}>oofda</#{e}></name></mods>", false)
          if e == 'description'
            expect(@mods_rec.personal_name.description_el.text).to eq('oofda')
          else
            expect(@mods_rec.personal_name.send(e).text).to eq('oofda')
          end
        }
      end
      it "should include name elements with type attr = personal" do
        @mods_rec.from_str(@mods_w_pers_name, false)
        expect(@mods_rec.personal_name.namePart.text).to eq(@pers_name)
        expect(@mods_rec.from_str(@mods_w_both, false).personal_name.namePart.text).to eq(@pers_name)
      end
      it "should not include name elements with type attr != personal" do
        @mods_rec.from_str(@mods_w_corp_name, false)
        expect(@mods_rec.personal_name.namePart.text).to eq("")
        expect(@mods_rec.from_str(@mods_w_both, false).personal_name.namePart.text).not_to match(@corp_name)
      end

      context "roles" do
        it "should be possible to access a personal_name role easily" do
          @mods_rec.from_str(@mods_w_pers_name_role, false)
          expect(@mods_rec.personal_name.role.text).to include(@pers_role)
        end
        it "should get role type" do
          @mods_rec.from_str(@mods_w_pers_name_role, false)
          expect(@mods_rec.personal_name.role.roleTerm.type_at).to eq(["text"])
          @mods_rec.from_str(@mods_w_pers_name_role_code, false)
          expect(@mods_rec.personal_name.role.roleTerm.type_at).to eq(["code"])
        end
        it "should get role authority" do
          @mods_rec.from_str(@mods_w_pers_name_role, false)
          expect(@mods_rec.personal_name.role.roleTerm.authority).to eq(["marcrelator"])
        end
      end # roles    
    end # WITHOUT namespaces

    # note that Mods::Record.personal_names tests are in record_spec
    
  end # personal name
  
  context "corporate name" do    
    context "WITH namespaces" do
      it "should recognize child elements" do
        Mods::Name::CHILD_ELEMENTS.reject{|e| e == "role" }.each { |e|
          @mods_rec.from_str("<mods #{@ns_decl}><name type='corporate'><#{e}>oofda</#{e}></name></mods>")
          if e == 'description'
            expect(@mods_rec.corporate_name.description_el.text).to eq('oofda')
          else
            expect(@mods_rec.corporate_name.send(e).text).to eq('oofda')
          end
        }
      end
      it "should include name elements with type attr = corporate" do
        @mods_rec.from_str(@mods_w_corp_name_ns)
        expect(@mods_rec.corporate_name.namePart.text).to eq(@corp_name)
        expect(@mods_rec.from_str(@mods_w_both_ns).corporate_name.namePart.text).to eq(@corp_name)
      end
      it "should not include name elements with type attr != corporate" do
        @mods_rec.from_str(@mods_w_pers_name_ns)
        expect(@mods_rec.corporate_name.namePart.text).to eq("")
        expect(@mods_rec.from_str(@mods_w_both_ns).corporate_name.namePart.text).not_to match(@pers_name)
      end
    end # WITH namespaces
    context "WITHOUT namespaces" do
      it "should recognize child elements" do
        Mods::Name::CHILD_ELEMENTS.reject{|e| e == "role" }.each { |e|
          @mods_rec.from_str("<mods><name type='corporate'><#{e}>oofda</#{e}></name></mods>", false)
          if e == 'description'
            expect(@mods_rec.corporate_name.description_el.text).to eq('oofda')
          else
            expect(@mods_rec.corporate_name.send(e).text).to eq('oofda')
          end
        }
      end
      it "should include name elements with type attr = corporate" do
        @mods_rec.from_str(@mods_w_corp_name, false)
        expect(@mods_rec.corporate_name.namePart.text).to eq(@corp_name)
        expect(@mods_rec.from_str(@mods_w_both, false).corporate_name.namePart.text).to eq(@corp_name)
      end
      it "should not include name elements with type attr != corporate" do
        @mods_rec.from_str(@mods_w_pers_name, false)
        expect(@mods_rec.corporate_name.namePart.text).to eq("")
        expect(@mods_rec.from_str(@mods_w_both, false).corporate_name.namePart.text).not_to match(@pers_name)
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
            expect(@mods_rec.plain_name.description_el.text).to eq('oofda')
          else
            expect(@mods_rec.plain_name.send(e).text).to eq('oofda')
          end
        }
      end
      it "should recognize attributes on name node" do
        Mods::Name::ATTRIBUTES.each { |attrb| 
          @mods_rec.from_str("<mods #{@ns_decl}><name #{attrb}='hello'><displayForm>q</displayForm></name></mods>")
          if attrb != 'type'
            expect(@mods_rec.plain_name.send(attrb)).to eq(['hello'])
          else
            expect(@mods_rec.plain_name.type_at).to eq(['hello'])
          end
        }
      end
      context "namePart child element" do
        it "should recognize type attribute on namePart element" do
          Mods::Name::NAME_PART_TYPES.each { |t|  
            @mods_rec.from_str("<mods #{@ns_decl}><name><namePart type='#{t}'>hi</namePart></name></mods>")
            expect(@mods_rec.plain_name.namePart.type_at).to eq([t])
          }
        end
      end
      context "role child element" do
        it "should get role type" do
          @mods_rec.from_str(@mods_w_pers_name_role_ns)
          expect(@mods_rec.plain_name.role.roleTerm.type_at).to eq(["text"])
          @mods_rec.from_str(@mods_w_pers_name_role_code_ns)
          expect(@mods_rec.plain_name.role.roleTerm.type_at).to eq(["code"])
        end
        it "should get role authority" do
          @mods_rec.from_str(@mods_w_pers_name_role_ns)
          expect(@mods_rec.plain_name.role.roleTerm.authority).to eq(["marcrelator"])
        end
      end
      
    end # context WITH namespaces (plain_name)

    context "WITHOUT namespaces" do
      it "should recognize child elements" do
        Mods::Name::CHILD_ELEMENTS.reject{|e| e == "role"}.each { |e|
          @mods_rec.from_str("<mods><name><#{e}>oofda</#{e}></name></mods>", false)
          if e == 'description'
            expect(@mods_rec.plain_name.description_el.text).to eq('oofda')
          else
            expect(@mods_rec.plain_name.send(e).text).to eq('oofda')
          end
        }
      end
      it "should recognize attributes on name node" do
        Mods::Name::ATTRIBUTES.each { |attrb| 
          @mods_rec.from_str("<mods><name #{attrb}='hello'><displayForm>q</displayForm></name></mods>", false)
          if attrb != 'type'
            expect(@mods_rec.plain_name.send(attrb)).to eq(['hello'])
          else
            expect(@mods_rec.plain_name.type_at).to eq(['hello'])
          end
        }
      end
      context "namePart child element" do
        it "should recognize type attribute on namePart element" do
          Mods::Name::NAME_PART_TYPES.each { |t|  
            @mods_rec.from_str("<mods><name><namePart type='#{t}'>hi</namePart></name></mods>", false)
            expect(@mods_rec.plain_name.namePart.type_at).to eq([t])
          }
        end
      end
      context "role child element" do
        it "should get role type" do
          @mods_rec.from_str(@mods_w_pers_name_role, false)
          expect(@mods_rec.plain_name.role.roleTerm.type_at).to eq(["text"])
          @mods_rec.from_str(@mods_w_pers_name_role_code, false)
          expect(@mods_rec.plain_name.role.roleTerm.type_at).to eq(["code"])
        end
        it "should get role authority" do
          @mods_rec.from_str(@mods_w_pers_name_role, false)
          expect(@mods_rec.plain_name.role.roleTerm.authority).to eq(["marcrelator"])
        end
      end
    end # context WITHOUT namespaces

  end # plain name
  
  it "should be able to translate the marc relator code into text" do
    expect(MARC_RELATOR['drt']).to eq("Director")
  end
  
  context "display_value and display_value_w_date" do
    before(:all) do
      @disp_form = 'q'
      @pname1_xml = "<mods #{@ns_decl}><name type='personal'>
              <namePart type='given'>John</namePart>
              <namePart type='family'>Huston</namePart>
              <displayForm>#{@disp_form}</displayForm>
         </name></mods>"
      @cname_xml = "<mods #{@ns_decl}><name type='corporate'>
              <namePart>Watchful Eye</namePart>
          </name></mods>"
      @affl = 'affliation'
      @desc = 'description'
      @role = 'role'
      @name_xml = "<mods #{@ns_decl}><name>
                <namePart>Exciting Prints</namePart>
                <affiliation>#{@affl}</affiliation>
                <description>#{@desc}</description>
                <role><roleTerm type='text'>#{@role}</roleTerm></role>
            </name></mods>"
      @namepart_xml = "<mods #{@ns_decl}><name>
                <namePart>Suzy</namePart>
                <namePart type='date'>1920-</namePart>
            </name></mods>"
    end
    context "WITH namespaces" do
      before(:all) do
        @mods_pname1 = Mods::Record.new.from_str(@pname1_xml)
        @mods_cname = Mods::Record.new.from_str(@cname_xml)
        @mods_name = Mods::Record.new.from_str(@name_xml)
        @mods_namepart_date = Mods::Record.new.from_str(@namepart_xml)        
      end
      it "should be a string value for each name, not an Array" do
        expect(@mods_name.plain_name.first.display_value).to be_an_instance_of(String)
        expect(@mods_name.plain_name.first.display_value_w_date).to be_an_instance_of(String)
      end
      it "should return nil when there is no display_value" do
        x = "<mods #{@ns_decl}><name>
                  <namePart></namePart>
              </name></mods>"
        r = Mods::Record.new.from_str(x)
        expect(r.plain_name.first.display_value).to eq(nil)
      end
      it "should be applicable to all name term flavors (plain_name, personal_name, corporate_name ...)" do
        expect(@mods_name.plain_name.first.display_value).not_to eq(nil)
        expect(@mods_name.plain_name.first.display_value_w_date).not_to eq(nil)
        expect(@mods_pname1.personal_name.first.display_value).not_to eq(nil)
        expect(@mods_pname1.personal_name.first.display_value_w_date).not_to eq(nil)
        expect(@mods_cname.corporate_name.first.display_value).not_to eq(nil)
        expect(@mods_cname.corporate_name.first.display_value_w_date).not_to eq(nil)
      end
      it "should not include <affiliation> text" do
        expect(@mods_name.plain_name.first.display_value).not_to match(Regexp.new(@affl))
      end
      it "should not include <description> text" do
        expect(@mods_name.plain_name.first.display_value).not_to match(Regexp.new(@desc))
      end
      it "should not include <role> info" do
        expect(@mods_name.plain_name.first.display_value).not_to match(Regexp.new(@role))
      end
      it "should be the value of the <displayForm> subelement if it exists" do
        expect(@mods_pname1.plain_name.first.display_value).to eq(@disp_form)
        x = "<mods #{@ns_decl}><name type='personal'>
              	  <namePart>Alterman, Eric</namePart>
              	  <displayForm>Eric Alterman</displayForm>
              </name><mods>"
        r = Mods::Record.new.from_str(x)         
        expect(r.plain_name.first.display_value).to eq('Eric Alterman')
      end
      it "display_value should not include <namePart type='date'>" do
        expect(@mods_namepart_date.plain_name.first.display_value).to eq('Suzy')
      end
      it "date text should be added to display_value_w_date when it is available" do
        expect(@mods_namepart_date.plain_name.first.display_value_w_date).to eq('Suzy, 1920-')
      end
      it "date text should not be added to display_value_w_dates if dates are already included" do
        x = "<mods #{@ns_decl}><name>
                  <namePart>Woolf, Virginia</namePart>
  	              <namePart type='date'>1882-1941</namePart>
                  <displayForm>Woolf, Virginia, 1882-1941</namePart>
              </name></mods>"
        r = Mods::Record.new.from_str(x) 
        expect(r.plain_name.first.display_value_w_date).to eq('Woolf, Virginia, 1882-1941')
      end
      context "personal names" do
        before(:all) do
          @d = '1920-2005'
          x = "<mods #{@ns_decl}><name type='personal'>
                	<namePart type='given'>John Paul</namePart>
                	<namePart type='termsOfAddress'>II</namePart>
                	<namePart type='termsOfAddress'>Pope</namePart>
                	<namePart type='date'>#{@d}</namePart>
              </name></mods>"
          @pope = Mods::Record.new.from_str(x) 
          x = "<mods #{@ns_decl}><name type='personal'>
                    <namePart>Crusty</namePart>
                    <namePart>The Clown</namePart>
                    <namePart type='date'>#{@d}</namePart>
                </name></mods>"
          @pname2 = Mods::Record.new.from_str(x)
        end
        # use the displayForm of a personal name if present
        #   if no displayForm, try to make a string from family name and given name "family_name, given_name"
        #   otherwise, return all nameParts concatenated together
        # @return Array of Strings, each containing the above described string
        it "should be [family name], [given name] if they are present" do
          x = "<mods #{@ns_decl}><name type='personal'>
                  <namePart type='given'>John</namePart>
                  <namePart type='family'>Huston</namePart>
             </name></mods>"
          r = Mods::Record.new.from_str(x)
          expect(r.personal_name.first.display_value).to eq('Huston, John')
          expect(@pope.personal_name.first.display_value).to eq('John Paul II, Pope')
        end
        it "should be concatenation of untyped <namePart> elements if there is no family or given name" do
          expect(@pname2.personal_name.first.display_value).to eq('Crusty The Clown')
        end
        it "should include <termOfAddress> elements, in order, comma separated" do
          expect(@pope.personal_name.first.display_value).to eq('John Paul II, Pope')
        end
        it "display_value should not include date" do
          expect(@pope.personal_name.first.display_value).not_to match(Regexp.new(@d))
        end
        it "date should be included in display_value_w_date" do
          expect(@pope.personal_name.first.display_value_w_date).to eq("John Paul II, Pope, #{@d}")
        end
      end
      context "not personal name (e.g. corporate)" do
        it "should be the value of non-date nameParts concatenated" do
          x = "<mods #{@ns_decl}><name type='corporate'>
            	<namePart>United States</namePart>
            	<namePart>Court of Appeals (2nd Circuit)</namePart>
          </name></mods>"
          r = Mods::Record.new.from_str(x)
          expect(r.corporate_name.first.display_value).to eq('United States Court of Appeals (2nd Circuit)')
        end
      end
    end # WITH namespaces

    context "WITHOUT namespaces" do
      before(:all) do
        @mods_pname1 = Mods::Record.new.from_str(@pname1_xml.sub(" #{@ns_decl}", ''), false)
        @mods_cname = Mods::Record.new.from_str(@cname_xml.sub(" #{@ns_decl}", ''), false)
        @mods_name = Mods::Record.new.from_str(@name_xml.sub(" #{@ns_decl}", ''), false)
        @mods_namepart_date = Mods::Record.new.from_str(@namepart_xml.sub(" #{@ns_decl}", ''), false)
      end
      it "should be a string value for each name, not an Array" do
        expect(@mods_name.plain_name.first.display_value).to be_an_instance_of(String)
        expect(@mods_name.plain_name.first.display_value_w_date).to be_an_instance_of(String)
      end
      it "should return nil when there is no display_value" do
        x = "<mods><name>
                  <namePart></namePart>
              </name></mods>"
        r = Mods::Record.new.from_str(x, false)
        expect(r.plain_name.first.display_value).to eq(nil)
      end
      it "should be applicable to all name term flavors (plain_name, personal_name, corporate_name ...)" do
        expect(@mods_name.plain_name.first.display_value).not_to eq(nil)
        expect(@mods_name.plain_name.first.display_value_w_date).not_to eq(nil)
        expect(@mods_pname1.personal_name.first.display_value).not_to eq(nil)
        expect(@mods_pname1.personal_name.first.display_value_w_date).not_to eq(nil)
        expect(@mods_cname.corporate_name.first.display_value).not_to eq(nil)
        expect(@mods_cname.corporate_name.first.display_value_w_date).not_to eq(nil)
      end
      it "should not include <affiliation> text" do
        expect(@mods_name.plain_name.first.display_value).not_to match(Regexp.new(@affl))
      end
      it "should not include <description> text" do
        expect(@mods_name.plain_name.first.display_value).not_to match(Regexp.new(@desc))
      end
      it "should not include <role> info" do
        expect(@mods_name.plain_name.first.display_value).not_to match(Regexp.new(@role))
      end
      it "should be the value of the <displayForm> subelement if it exists" do
        expect(@mods_pname1.plain_name.first.display_value).to eq(@disp_form)
        x = "<mods><name type='personal'>
              	  <namePart>Alterman, Eric</namePart>
              	  <displayForm>Eric Alterman</displayForm>
              </name><mods>"
        r = Mods::Record.new.from_str(x, false)         
        expect(r.plain_name.first.display_value).to eq('Eric Alterman')
      end
      it "display_value should not include <namePart type='date'>" do
        expect(@mods_namepart_date.plain_name.first.display_value).to eq('Suzy')
      end
      it "date text should be added to display_value_w_date when it is available" do
        expect(@mods_namepart_date.plain_name.first.display_value_w_date).to eq('Suzy, 1920-')
      end
      it "date text should not be added to display_value_w_dates if dates are already included" do
        x = "<mods><name>
                  <namePart>Woolf, Virginia</namePart>
  	              <namePart type='date'>1882-1941</namePart>
                  <displayForm>Woolf, Virginia, 1882-1941</namePart>
              </name></mods>"
        r = Mods::Record.new.from_str(x, false) 
        expect(r.plain_name.first.display_value_w_date).to eq('Woolf, Virginia, 1882-1941')
      end
      context "personal names" do
        before(:all) do
          @d = '1920-2005'
          x = "<mods><name type='personal'>
                	<namePart type='given'>John Paul</namePart>
                	<namePart type='termsOfAddress'>II</namePart>
                	<namePart type='termsOfAddress'>Pope</namePart>
                	<namePart type='date'>#{@d}</namePart>
              </name></mods>"
          @pope = Mods::Record.new.from_str(x, false) 
          x = "<mods><name type='personal'>
                    <namePart>Crusty</namePart>
                    <namePart>The Clown</namePart>
                    <namePart type='date'>#{@d}</namePart>
                </name></mods>"
          @pname2 = Mods::Record.new.from_str(x, false)
        end
        # use the displayForm of a personal name if present
        #   if no displayForm, try to make a string from family name and given name "family_name, given_name"
        #   otherwise, return all nameParts concatenated together
        # @return Array of Strings, each containing the above described string
        it "should be [family name], [given name] if they are present" do
          x = "<mods><name type='personal'>
                  <namePart type='given'>John</namePart>
                  <namePart type='family'>Huston</namePart>
             </name></mods>"
          r = Mods::Record.new.from_str(x, false)
          expect(r.personal_name.first.display_value).to eq('Huston, John')
          expect(@pope.personal_name.first.display_value).to eq('John Paul II, Pope')
        end
        it "should be concatenation of untyped <namePart> elements if there is no family or given name" do
          expect(@pname2.personal_name.first.display_value).to eq('Crusty The Clown')
        end
        it "should include <termOfAddress> elements, in order, comma separated" do
          expect(@pope.personal_name.first.display_value).to eq('John Paul II, Pope')
        end
        it "display_value should not include date" do
          expect(@pope.personal_name.first.display_value).not_to match(Regexp.new(@d))
        end
        it "date should be included in display_value_w_date" do
          expect(@pope.personal_name.first.display_value_w_date).to eq("John Paul II, Pope, #{@d}")
        end
      end
      context "not personal name (e.g. corporate)" do
        it "should be the value of non-date nameParts concatenated" do
          x = "<mods><name type='corporate'>
            	<namePart>United States</namePart>
            	<namePart>Court of Appeals (2nd Circuit)</namePart>
          </name></mods>"
          r = Mods::Record.new.from_str(x, false)
          expect(r.corporate_name.first.display_value).to eq('United States Court of Appeals (2nd Circuit)')
        end
      end
    end # WITHOUT namespaces
  end # display_value and display_value_w_date
  
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
          expect(@mods_w_text.plain_name.role.value).to eq(["Actor"])
        end  
        it "should be the translation of the code if it is a marcrelator code and there is no text roleTerm" do
          expect(@mods_w_code.plain_name.role.value).to eq(["Director"])
        end
        it "should be the value of the text roleTerm if there are both a code and a text roleTerm" do
          expect(@mods_w_both.plain_name.role.value).to eq(["CreatorFake"])
        end
        it "should have 2 values if there are 2 role elements" do
          expect(@mods_mult_roles.plain_name.role.value).to eq(['Creator', 'Performer'])
        end
      end
      context "authority" do
        it "should be empty if it is missing from xml" do
          expect(@mods_wo_authority.plain_name.role.authority.size).to eq(0)
        end
        it "should be the value of the authority attribute on the roleTerm element" do
          expect(@mods_w_code.plain_name.role.authority).to eq(["marcrelator"])
          expect(@mods_w_text.plain_name.role.authority).to eq(["marcrelator"])
          expect(@mods_w_both.plain_name.role.authority).to eq(["marcrelator"])
        end
      end
      context "code" do
        it "should be empty if the roleTerm is not of type code" do
          expect(@mods_w_text.plain_name.role.code.size).to eq(0)
          expect(@mods_wo_authority.plain_name.role.code.size).to eq(0)
        end
        it "should be the value of the roleTerm element if element's type attribute is 'code'" do
          expect(@mods_w_code.plain_name.role.code).to eq(["drt"])
          expect(@mods_w_both.plain_name.role.code).to eq(["cre"])
        end
      end
      context "pertaining to a specific name" do
        before(:all) do
          complex = "<mods #{@ns_decl}>
                <name>
                    <namePart>Sean Connery</namePart>
                    <role><roleTerm type='code' authority='marcrelator'>drt</roleTerm></role>
                </name>
                <name>
                    <namePart>Pierce Brosnan</namePart>
                    <role>
                      <roleTerm type='text'>CreatorFake</roleTerm>
                      <roleTerm type='code' authority='marcrelator'>cre</roleTerm>
                    </role>
                    <role><roleTerm type='text' authority='marcrelator'>Actor</roleTerm></role>
                </name>
                <name>
                    <namePart>Daniel Craig</namePart>
                    <role>
                      <roleTerm type='text' authority='marcrelator'>Actor</roleTerm>
                      <roleTerm type='code' authority='marcrelator'>cre</roleTerm>
                    </role>
                </name>
              </mods>"
          @mods_complex = Mods::Record.new.from_str(complex)
        end
        it "roles should be empty array when there is no role element" do
          @mods_rec.from_str(@mods_w_pers_name_ns)
          expect(@mods_rec.personal_name.first.role.size).to eq(0)
        end
        it "object should have same number of roles as it has role nodes in xml" do
          expect(@mods_complex.plain_name[0].role.size).to eq(1)
          expect(@mods_complex.plain_name[1].role.size).to eq(2)
          expect(@mods_complex.plain_name[2].role.size).to eq(1)
        end
        context "name's roles should be correctly populated" do
          it "text attribute" do
            expect(@mods_complex.plain_name[0].role.value).to eq(['Director'])
            expect(@mods_complex.plain_name[1].role.value).to eq(['CreatorFake', 'Actor'])
            expect(@mods_complex.plain_name[2].role.value).to eq(['Actor'])
          end
          it "code attribute" do
            expect(@mods_complex.plain_name[0].role.code).to eq(['drt'])
            expect(@mods_complex.plain_name[1].role.code).to eq(['cre'])
            expect(@mods_complex.plain_name[2].role.code).to eq(['cre'])
          end
          it "authority attribute" do
            expect(@mods_complex.plain_name[0].role.authority).to eq(['marcrelator'])
            expect(@mods_complex.plain_name[1].role.authority).to eq(['marcrelator', 'marcrelator'])
            expect(@mods_complex.plain_name[2].role.authority).to eq(['marcrelator'])
          end
          it "multiple roles" do
            expect(@mods_mult_roles.plain_name.first.role.value).to eq(['Creator', 'Performer'])
            expect(@mods_mult_roles.plain_name.first.role.code).to eq(['cre'])
            expect(@mods_mult_roles.plain_name.role.first.roleTerm.authority.first).to eq('marcrelator')
            expect(@mods_mult_roles.plain_name.role.last.roleTerm.authority.size).to eq(0)
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
          expect(@mods_w_text.plain_name.role.value).to eq(["Actor"])
        end  
        it "should be the translation of the code if it is a marcrelator code and there is no text roleTerm" do
          expect(@mods_w_code.plain_name.role.value).to eq(["Director"])
        end
        it "should be the value of the text roleTerm if there are both a code and a text roleTerm" do
          expect(@mods_w_both.plain_name.role.value).to eq(["CreatorFake"])
        end
        it "should have 2 values if there are 2 role elements" do
          expect(@mods_mult_roles.plain_name.role.value).to eq(['Creator', 'Performer'])
        end
      end
      context "authority" do
        it "should be empty if it is missing from xml" do
          expect(@mods_wo_authority.plain_name.role.authority.size).to eq(0)
        end
        it "should be the value of the authority attribute on the roleTerm element" do
          expect(@mods_w_code.plain_name.role.authority).to eq(["marcrelator"])
          expect(@mods_w_text.plain_name.role.authority).to eq(["marcrelator"])
          expect(@mods_w_both.plain_name.role.authority).to eq(["marcrelator"])
        end
      end
      context "code" do
        it "should be empty if the roleTerm is not of type code" do
          expect(@mods_w_text.plain_name.role.code.size).to eq(0)
          expect(@mods_wo_authority.plain_name.role.code.size).to eq(0)
        end
        it "should be the value of the roleTerm element if element's type attribute is 'code'" do
          expect(@mods_w_code.plain_name.role.code).to eq(["drt"])
          expect(@mods_w_both.plain_name.role.code).to eq(["cre"])
        end
      end
      context "pertaining to a specific name" do
        before(:all) do
          complex = "<mods>
                <name>
                    <namePart>Sean Connery</namePart>
                    <role><roleTerm type='code' authority='marcrelator'>drt</roleTerm></role>
                </name>
                <name>
                    <namePart>Pierce Brosnan</namePart>
                    <role>
                      <roleTerm type='text'>CreatorFake</roleTerm>
                      <roleTerm type='code' authority='marcrelator'>cre</roleTerm>
                    </role>
                    <role><roleTerm type='text' authority='marcrelator'>Actor</roleTerm></role>
                </name>
                <name>
                    <namePart>Daniel Craig</namePart>
                    <role>
                      <roleTerm type='text' authority='marcrelator'>Actor</roleTerm>
                      <roleTerm type='code' authority='marcrelator'>cre</roleTerm>
                    </role>
                </name>
              </mods>"
          @mods_complex = Mods::Record.new.from_str(complex, false)
        end
        it "roles should be empty array when there is no role element" do
          @mods_rec.from_str(@mods_w_pers_name_ns)
          expect(@mods_rec.personal_name.first.role.size).to eq(0)
        end
        it "object should have same number of roles as it has role nodes in xml" do
          expect(@mods_complex.plain_name[0].role.size).to eq(1)
          expect(@mods_complex.plain_name[1].role.size).to eq(2)
          expect(@mods_complex.plain_name[2].role.size).to eq(1)
        end
        context "name's roles should be correctly populated" do
          it "text attribute" do
            expect(@mods_complex.plain_name[0].role.value).to eq(['Director'])
            expect(@mods_complex.plain_name[1].role.value).to eq(['CreatorFake', 'Actor'])
            expect(@mods_complex.plain_name[2].role.value).to eq(['Actor'])
          end
          it "code attribute" do
            expect(@mods_complex.plain_name[0].role.code).to eq(['drt'])
            expect(@mods_complex.plain_name[1].role.code).to eq(['cre'])
            expect(@mods_complex.plain_name[2].role.code).to eq(['cre'])
          end
          it "authority attribute" do
            expect(@mods_complex.plain_name[0].role.authority).to eq(['marcrelator'])
            expect(@mods_complex.plain_name[1].role.authority).to eq(['marcrelator', 'marcrelator'])
            expect(@mods_complex.plain_name[2].role.authority).to eq(['marcrelator'])
          end
          it "multiple roles" do
            expect(@mods_mult_roles.plain_name.first.role.value).to eq(['Creator', 'Performer'])
            expect(@mods_mult_roles.plain_name.first.role.code).to eq(['cre'])
            expect(@mods_mult_roles.plain_name.role.first.roleTerm.authority.first).to eq('marcrelator')
            expect(@mods_mult_roles.plain_name.role.last.roleTerm.authority.size).to eq(0)
          end      
        end
      end # pertaining to a specific name
    end # WITHOUT namespaces        
  end # roles
  
end