require 'spec_helper'
require 'equivalent-xml'

describe Mods::Role do
  
  before(:all) do
    @mods_rec = Mods::Record.new
    @ns_decl = "xmlns='#{Mods::MODS_NS}'"
    
    xml = "<mods #{@ns_decl}><name><namePart>Alfred Hitchock</namePart>
              <role><roleTerm type='code' authority='marcrelator'>drt</roleTerm></role>
          </name></mods>"
    @mods_rec.from_str xml
    @role_obj_w_code = Mods::Role.new(@mods_rec.plain_name.role.first)
    xml = "<mods #{@ns_decl}><name><namePart>Sean Connery</namePart>
              <role><roleTerm type='text' authority='marcrelator'>Actor</roleTerm></role>
          </name></mods>"
    @mods_rec.from_str xml
    @role_obj_w_text = Mods::Role.new(@mods_rec.plain_name.role.first)
    @role_xml = "<role><roleTerm type='text'>lithographer</roleTerm></role>"
    xml = "<mods #{@ns_decl}><name><namePart>Exciting Prints</namePart>
              #{@role_xml}
          </name></mods>"
    @mods_rec.from_str xml
    @role_obj_wo_authority = Mods::Role.new(@mods_rec.plain_name.role.first)
    xml = "<mods #{@ns_decl}><name><namePart>anyone</namePart>
              <role>
                <roleTerm type='text' authority='marcrelator'>CreatorFake</roleTerm>
                <roleTerm type='code' authority='marcrelator'>cre</roleTerm>
              </role>
          </name></mods>"
    @mods_rec.from_str xml
    @role_obj_w_both = Mods::Role.new(@mods_rec.plain_name.role.first)
  end

  it "should have a ng_node attribute" do
    ng_node = @role_obj_wo_authority.ng_node
    ng_node.should_not == nil
    ng_node.should be_an_instance_of(Nokogiri::XML::Element)
    ng_node.to_s.should be_equivalent_to(@role_xml)
  end
  
  context "text" do
    it "should be the value of a text roleTerm" do
      @role_obj_w_text.text.should == 'Actor'
    end  
    it "should be the translation of the code if it is a marcrelator code and there is no text roleTerm" do
      @role_obj_w_code.text.should == 'Director'
    end
    it "should be the value of the text roleTerm if there are both a code and a text roleTerm" do
      @role_obj_w_both.text.should == 'CreatorFake'
    end
  end
  
  context "authority" do
    it "should be nil if it is missing from xml" do
      @role_obj_wo_authority.authority.should == nil
    end
    it "should be the value of the authority attribute on the roleTerm element" do
      @role_obj_w_code.authority.should == 'marcrelator'
      @role_obj_w_text.authority.should == 'marcrelator'
      @role_obj_w_both.authority.should == 'marcrelator'
    end
  end
  
  context "code" do
    it "should be nil if the roleTerm is not of type code" do
      @role_obj_w_text.code.should == nil
      @role_obj_wo_authority.code.should == nil
    end
    it "should be the value of the roleTerm element if element's type attribute is 'code'" do
      @role_obj_w_code.code.should == 'drt'
      @role_obj_w_both.code.should == 'cre'
    end
  end

end