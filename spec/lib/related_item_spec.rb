require 'spec_helper'

describe "Mods <relatedItem> Element" do
  before(:all) do
    @mods_rec = Mods::Record.new
    @ns_decl = "xmlns='#{Mods::MODS_NS}'"
  end

  context "basic <related_item> terminology pieces" do

    context "WITH namespaces" do
      before(:all) do
        @rel_it1 = @mods_rec.from_str("<mods #{@ns_decl}><relatedItem displayLabel='Bibliography' type='host'>
                            <titleInfo>
                                <title/>
                            </titleInfo>
                            <recordInfo>
                                <recordIdentifier source='Gallica ARK'/>
                            </recordInfo>
                            <typeOfResource>text</typeOfResource>
                        </relatedItem></mods>").related_item
        @rel_it_mult = @mods_rec.from_str("<mods #{@ns_decl}><relatedItem>
                            <titleInfo>
                               <title>Complete atlas, or, Distinct view of the known world</title>
                            </titleInfo>
                            <name type='personal'>
                               <namePart>Bowen, Emanuel,</namePart>
                               <namePart type='date'>d. 1767</namePart>
                            </name>
                         </relatedItem>
                         <relatedItem type='host' displayLabel='From:'>
                            <titleInfo>
                               <title>Complete atlas, or, Distinct view of the known world</title>
                            </titleInfo>
                            <name>
                               <namePart>Bowen, Emanuel, d. 1767.</namePart>
                            </name>
                            <identifier type='local'>(AuCNL)1669726</identifier>
                         </relatedItem></mods>").related_item
        @rel_it2 = @mods_rec.from_str("<mods #{@ns_decl}><relatedItem type='constituent' ID='MODSMD_ARTICLE1'>
                           	<titleInfo>
                           	  	<title>Nuppineula.</title>
                           	</titleInfo>
                           	<genre>article</genre>
                           	<part ID='DIVL15' type='paragraph' order='1'/>
                           	<part ID='DIVL17' type='paragraph' order='2'/>
                           	<part ID='DIVL19' type='paragraph' order='3'/>
                         </relatedItem></mods>").related_item
        @coll_ex = @mods_rec.from_str("<mods #{@ns_decl}><relatedItem type='host'>
                           <titleInfo>
                             <title>The Collier Collection of the Revs Institute for Automotive Research</title>
                           </titleInfo>
                           <typeOfResource collection='yes'/>
                         </relatedItem></mods>").related_item
      end

      it ".relatedItem should be a NodeSet" do
        [@rel_it1, @rel_it_mult, @rel_it2, @coll_ex].each { |ri| expect(ri).to be_an_instance_of(Nokogiri::XML::NodeSet) }
      end
      it ".relatedItem should have as many members as there are <recordInfo> elements in the xml" do
         [@rel_it1, @rel_it2, @coll_ex].each { |ri| expect(ri.size).to eq(1) }
         expect(@rel_it_mult.size).to eq(2)
      end
      it "relatedItem.type_at should match type attribute" do
        [@rel_it1, @rel_it_mult, @coll_ex].each { |ri| expect(ri.type_at).to eq(['host']) }
        expect(@rel_it2.type_at).to eq(['constituent'])
      end
      it "relatedItem.id_at should match ID attribute" do
        expect(@rel_it2.id_at).to eq(['MODSMD_ARTICLE1'])
        [@rel_it1, @rel_it_mult, @coll_ex].each { |ri| expect(ri.id_at.size).to eq(0) }
      end
      it "relatedItem.displayLabel should match displayLabel attribute" do
        expect(@rel_it1.displayLabel).to eq(['Bibliography'])
        expect(@rel_it_mult.displayLabel).to eq(['From:'])
        [@rel_it2, @coll_ex].each { |ri| expect(ri.displayLabel.size).to eq(0) }
      end

      context "<genre> child element" do
        it "relatedItem.genre should match <relatedItem><genre>" do
          expect(@rel_it2.genre.map { |ri| ri.text }).to eq(['article'])
        end
      end # <genre> child element

      context "<identifier> child element" do
        it "relatedItem.identifier.type_at should match <relatedItem><identifier type=''> attribute" do
          expect(@rel_it_mult.identifier.type_at).to eq(['local'])
        end
        it "relatedItem.identifier should match <relatedItem><identifier>" do
          expect(@rel_it_mult.identifier.map { |n| n.text }).to eq(['(AuCNL)1669726'])
        end
      end # <identifier> child element

      context "<name> child element" do
        it "relatedItem.personal_name.namePart should match <relatedItem><name type='personal'><namePart>" do
          expect(@rel_it_mult.personal_name.namePart.map { |n| n.text }.size).to eq(2)
          expect(@rel_it_mult.personal_name.namePart.map { |n| n.text }).to include('Bowen, Emanuel,')
          expect(@rel_it_mult.personal_name.namePart.map { |n| n.text }).to include('d. 1767')
          expect(@rel_it_mult.personal_name.namePart.map { |n| n.text }).not_to include('Bowen, Emanuel, d. 1767.')
        end
        it "relatedItem.personal_name.date should match <relatedItem><name type='personal'><namePart type='date'>" do
          expect(@rel_it_mult.personal_name.date.map { |n| n.text }).to eq(['d. 1767'])
        end
        it "relatedItem.name_el.namePart should match <relatedItem><name><namePart>" do
          expect(@rel_it_mult.name_el.namePart.map { |n| n.text }.size).to eq(3)
          expect(@rel_it_mult.name_el.namePart.map { |n| n.text }).to include('Bowen, Emanuel,')
          expect(@rel_it_mult.name_el.namePart.map { |n| n.text }).to include('d. 1767')
          expect(@rel_it_mult.name_el.namePart.map { |n| n.text }).to include('Bowen, Emanuel, d. 1767.')
        end
      end # <name> child element

      context "<part> child element" do
        it "relatedItem.part.type_at should match <relatedItem><part type=''> attribute" do
          expect(@rel_it2.part.type_at).to eq(['paragraph', 'paragraph', 'paragraph'])
        end
        it "relatedItem.part.id_at should match <relatedItem><part ID=''> attribute" do
          expect(@rel_it2.part.id_at.size).to eq(3)
          expect(@rel_it2.part.id_at).to include('DIVL15')
          expect(@rel_it2.part.id_at).to include('DIVL17')
          expect(@rel_it2.part.id_at).to include('DIVL19')
        end
        it "relatedItem.part.order should match <relatedItem><part order=''> attribute" do
          expect(@rel_it2.part.order.size).to eq(3)
          expect(@rel_it2.part.order).to include('1')
          expect(@rel_it2.part.order).to include('2')
          expect(@rel_it2.part.order).to include('3')
        end
      end # <part> child element

      context "<recordInfo> child element" do
        it "relatedItem.recordInfo.recordIdentifier.source should match <relatedItem><recordInfo><recordIdentifier source> attribute" do
          expect(@rel_it1.recordInfo.recordIdentifier.source).to eq(['Gallica ARK'])
        end
      end # <recordInfo> child element

      context "<titleInfo> child element" do
        it "relatedItem.titleInfo.title should access <relatedItem><titleInfo><title>" do
          expect(@rel_it1.titleInfo.title.map { |n| n.text }).to eq([''])
          expect(@rel_it_mult.titleInfo.title.map { |n| n.text }).to eq(['Complete atlas, or, Distinct view of the known world', 'Complete atlas, or, Distinct view of the known world'])
          expect(@rel_it2.titleInfo.title.map { |n| n.text }).to eq(['Nuppineula.'])
          expect(@coll_ex.titleInfo.title.map { |n| n.text }).to eq(['The Collier Collection of the Revs Institute for Automotive Research'])
        end
      end # <titleInfo> child element

      context "<typeOfResource> child element" do
        it "relatedItem.typeOfResource should access <relatedItem><typeOfResource>" do
          expect(@rel_it1.typeOfResource.map { |n| n.text }).to eq(['text'])
        end
        it "relatedItem.typeOfResource.collection should access <relatedItem><typeOfResource collection='yes'> attribute" do
          expect(@coll_ex.typeOfResource.collection).to eq(['yes'])
        end
      end # <typeOfResource> child element

    end # WITH namespaces
  end # basic <related_item> terminology pieces

end
