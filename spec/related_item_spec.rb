require 'spec_helper'

describe "Mods <relatedItem> Element" do
  before(:all) do
    @mods_rec = Mods::Record.new
    @rel_it1 = @mods_rec.from_str('<mods><relatedItem displayLabel="Bibliography" type="host">
                        <titleInfo>
                            <title/>
                        </titleInfo>
                        <recordInfo>
                            <recordIdentifier source="Gallica ARK"/>
                        </recordInfo>
                        <typeOfResource>text</typeOfResource>
                    </relatedItem></mods>').related_item
    @rel_it_mult = @mods_rec.from_str('<mods><relatedItem>
                        <titleInfo>
                           <title>Complete atlas, or, Distinct view of the known world</title>
                        </titleInfo>
                        <name type="personal">
                           <namePart>Bowen, Emanuel,</namePart>
                           <namePart type="date">d. 1767</namePart>
                        </name>
                     </relatedItem>
                     <relatedItem type="host" displayLabel="From:">
                        <titleInfo>
                           <title>Complete atlas, or, Distinct view of the known world</title>
                        </titleInfo>
                        <name>
                           <namePart>Bowen, Emanuel, d. 1767.</namePart>
                        </name>
                        <identifier type="local">(AuCNL)1669726</identifier>
                     </relatedItem></mods>').related_item
    @rel_it2 = @mods_rec.from_str('<mods><relatedItem type="constituent" ID="MODSMD_ARTICLE1">
                       	<titleInfo>
                       	  	<title>Nuppineula.</title>
                       	<genre>article</genre>
                       	<part ID="DIVL15" type="paragraph" order="1"/>
                       	<part ID="DIVL17" type="paragraph" order="2"/>
                       	<part ID="DIVL19" type="paragraph" order="3"/>
                     </relatedItem></mods>').related_item
    @coll_ex = @mods_rec.from_str('<mods><relatedItem type="host">
                       <titleInfo>
                         <title>The Collier Collection of the Revs Institute for Automotive Research</title>
                       </titleInfo>
                       <typeOfResource collection="yes"/>
                     </relatedItem></mods>').related_item
  end
  
  it "should associate the right pieces with the right <relatedItem> elements" do
    pending "to be implemented (Mods::RelatedItem object)"
  end

  context "basic <related_item> terminology pieces" do
    
    it ".relatedItem should be a NodeSet" do
      [@rel_it1, @rel_it_mult, @rel_it2, @coll_ex].each { |ri| ri.should be_an_instance_of(Nokogiri::XML::NodeSet) }
    end
    it ".relatedItem should have as many members as there are <recordInfo> elements in the xml" do
       [@rel_it1, @rel_it2, @coll_ex].each { |ri| ri.size.should == 1 }
       @rel_it_mult.size.should == 2
    end
    it "relatedItem.type_at should match type attribute" do
      [@rel_it1, @rel_it_mult, @coll_ex].each { |ri| ri.type_at.should == ['host'] }
      @rel_it2.type_at.should == ['constituent']
    end
    it "relatedItem.id_at should match ID attribute" do
      @rel_it2.id_at.should == ['MODSMD_ARTICLE1']
      [@rel_it1, @rel_it_mult, @coll_ex].each { |ri| ri.id_at.size.should == 0 }
    end
    it "relatedItem.displayLabel should match displayLabel attribute" do
      @rel_it1.displayLabel.should == ['Bibliography'] 
      @rel_it_mult.displayLabel.should == ['From:']
      [@rel_it2, @coll_ex].each { |ri| ri.displayLabel.size.should == 0 }
    end
    
    context "<genre> child element" do
      it "relatedItem.genre should match <relatedItem><genre>" do
        @rel_it2.genre.map { |ri| ri.text }.should == ['article']
      end
    end # <genre> child element
    
    context "<identifier> child element" do
      it "relatedItem.identifier.type_at should match <relatedItem><identifier type=''> attribute" do
        @rel_it_mult.identifier.type_at.should == ['local']
      end
      it "relatedItem.identifier should match <relatedItem><identifier>" do
        @rel_it_mult.identifier.map { |n| n.text }.should == ['(AuCNL)1669726']
      end
    end # <identifier> child element
    
    context "<name> child element" do
      it "relatedItem.personal_name.namePart should match <relatedItem><name type='personal'><namePart>" do
        @rel_it_mult.personal_name.namePart.map { |n| n.text }.size.should == 2
        @rel_it_mult.personal_name.namePart.map { |n| n.text }.should include('Bowen, Emanuel,')
        @rel_it_mult.personal_name.namePart.map { |n| n.text }.should include('d. 1767')
        @rel_it_mult.personal_name.namePart.map { |n| n.text }.should_not include('Bowen, Emanuel, d. 1767.')
      end
      it "relatedItem.personal_name.date should match <relatedItem><name type='personal'><namePart type='date'>" do
        @rel_it_mult.personal_name.date.map { |n| n.text }.should == ['d. 1767']
      end
      it "relatedItem.name_el.namePart should match <relatedItem><name><namePart>" do
        @rel_it_mult.name.namePart.map { |n| n.text }.size.should == 3
        @rel_it_mult.name.namePart.map { |n| n.text }.should include('Bowen, Emanuel,')
        @rel_it_mult.name.namePart.map { |n| n.text }.should include('d. 1767')
        @rel_it_mult.name.namePart.map { |n| n.text }.should include('Bowen, Emanuel, d. 1767.')
      end
    end # <name> child element

    context "<part> child element" do
      it "relatedItem.part.type_at should match <relatedItem><part type=''> attribute" do
        @rel_it2.part.type_at.should == ['paragraph', 'paragraph', 'paragraph']
      end
      it "relatedItem.part.id_at should match <relatedItem><part ID=''> attribute" do
        @rel_it2.part.id_at.size.should == 3
        @rel_it2.part.id_at.should include('DIVL15')
        @rel_it2.part.id_at.should include('DIVL17')
        @rel_it2.part.id_at.should include('DIVL19')
      end
      it "relatedItem.part.order should match <relatedItem><part order=''> attribute" do
        @rel_it2.part.order.size.should == 3
        @rel_it2.part.order.should include('1')
        @rel_it2.part.order.should include('2')
        @rel_it2.part.order.should include('3')
      end
    end # <part> child element

    context "<recordInfo> child element" do
      it "relatedItem.recordInfo.recordIdentifier.source should match <relatedItem><recordInfo><recordIdentifier source> attribute" do
        @rel_it1.recordInfo.recordIdentifier.source.should == ['Gallica ARK']
      end
    end # <recordInfo> child element    
        
    context "<titleInfo> child element" do
      it "relatedItem.titleInfo.title should access <relatedItem><titleInfo><title>" do
        @rel_it1.titleInfo.title.map { |n| n.text }.should == ['']
        @rel_it_mult.titleInfo.title.map { |n| n.text }.should == ['Complete atlas, or, Distinct view of the known world', 'Complete atlas, or, Distinct view of the known world']
        @rel_it2.titleInfo.title.map { |n| n.text }.should == ['Nuppineula.']
        @coll_ex.titleInfo.title.map { |n| n.text }.should == ['The Collier Collection of the Revs Institute for Automotive Research']
      end      
    end # <titleInfo> child element
    
    context "<typeOfResource> child element" do
      it "relatedItem.typeOfResource should access <relatedItem><typeOfResource>" do
        @rel_it1.typeOfResource.map { |n| n.text }.should == ['text']
      end
      it "relatedItem.typeOfResource.collection should access <relatedItem><typeOfResource collection=''> attribute" do
        @rel_it1.typeOfResource.collection.should == ['yes']
      end
    end # <typeOfResource> child element
    
  end # basic <related_item> terminology pieces

end