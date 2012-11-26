require 'spec_helper'

describe "Mods <location> Element" do
  before(:all) do
    @mods_rec = Mods::Record.new
  end

  context "basic location terminology pieces" do
    
    context "WITH namespaces" do
      before(:all) do
        @ns_decl = "xmlns='#{Mods::MODS_NS}'"
        @url_and_phys = "<mods #{@ns_decl}><location>
                    <url displayLabel='Digital collection of 46 images available online' usage='primary display'>http://searchworks.stanford.edu/?f%5Bcollection%5D%5B%5D=The+Reid+W.+Dennis+Collection+of+California+Lithographs&amp;view=gallery</url>
                  </location><location>
                    <physicalLocation>Department of Special Collections, Stanford University Libraries, Stanford, CA 94305.</physicalLocation>
                  </location></mods>"
        # from http://www.loc.gov/standards/mods/v3/mods-userguide-elements.html !!
        #  sublocation is not allowed directly under location
        @incorrect = "<mods #{@ns_decl}><location>
                        	<physicalLocation>Library of Congress </physicalLocation>
                        	<sublocation>Prints and Photographs Division Washington, D.C. 20540 USA</sublocation>
                        	<shelfLocator>DAG no. 1410</shelfLocator>
                      </location></mods>"
      end
      
      context "physicalLocation child element" do
        before(:all) do
          @phys_loc_only = "<mods #{@ns_decl}><location><physicalLocation>here</physicalLocation></location></mods>"
          @phys_loc_authority = "<mods #{@ns_decl}><location><physicalLocation authority='marcorg'>MnRM</physicalLocation></location></mods>"
        end
        it "should have access to text value of element" do
          @mods_rec.from_str(@phys_loc_only)
          @mods_rec.location.physicalLocation.text.should == "here"
          @mods_rec.from_str(@phys_loc_authority)
          @mods_rec.location.physicalLocation.map { |n| n.text }.should == ["MnRM"]
        end
        it "should recognize authority attribute" do
          @mods_rec.from_str(@phys_loc_authority)
          @mods_rec.location.physicalLocation.authority.should == ["marcorg"]
        end
        it "should recognize displayLabel attribute" do
          @mods_rec.from_str("<mods #{@ns_decl}><location><physicalLocation displayLabel='Correspondence'>some address</physicalLocation></location></mods>")
          @mods_rec.location.physicalLocation.displayLabel.should == ["Correspondence"]
        end      
      end

      it "shelfLocator child element" do
        shelf_loc = "<mods #{@ns_decl}><location>
                        	<physicalLocation>Library of Congress </physicalLocation>
                        	<shelfLocator>DAG no. 1410</shelfLocator>
                      </location></mods>"
        @mods_rec.from_str(shelf_loc)
        @mods_rec.location.shelfLocator.map { |n| n.text }.should == ["DAG no. 1410"]
      end

      context "url child element" do
        before(:all) do
          @empty_loc_url = "<mods #{@ns_decl}><location><url/></location></mods>"
          @mult_flavor_loc_urls = "<mods #{@ns_decl}><location>
                    	<url access='preview'>http://preview.org</url>
                    	<url access='object in context'>http://context.org</url>
                    	<url access='raw object'>http://object.org</url>
                  </location></mods>"
        end
        it "should have access to text value of element" do
          urls = @mods_rec.from_str(@mult_flavor_loc_urls).location.url.map { |e| e.text }
          urls.size.should == 3
          urls.should include("http://preview.org")
          urls.should include("http://context.org")
          urls.should include("http://object.org")
        end
        context "attributes" do
          before(:all) do
            @url_attribs = "<mods #{@ns_decl}><location>
                        <url displayLabel='Digital collection of 46 images available online' usage='primary display'>http://searchworks.stanford.edu/?f%5Bcollection%5D%5B%5D=The+Reid+W.+Dennis+Collection+of+California+Lithographs&amp;view=gallery</url>
                      </location></mods>"
          end
          it "should recognize displayLabel attribute" do
            @mods_rec.from_str(@url_attribs).location.url.displayLabel.should == ["Digital collection of 46 images available online"]
          end
          it "should recognize access attribute" do
            vals = @mods_rec.from_str(@mult_flavor_loc_urls).location.url.access
            vals.size.should == 3
            vals.should include("preview")
            vals.should include("object in context")
            vals.should include("raw object")
          end
          it "should recognize usage attribute" do
            @mods_rec.from_str(@url_attribs).location.url.usage.should == ["primary display"]
          end
          it "should recognize note attribute" do
            @mods_rec.from_str("<mods #{@ns_decl}><location><url note='something'>http://somewhere.org</url></location></mods>")
            @mods_rec.location.url.note.should == ["something"]
          end
          it "should recognize dateLastAccessed attribute" do
            @mods_rec.from_str("<mods #{@ns_decl}><location><url dateLastAccessed='something'>http://somewhere.org</url></location></mods>")
            @mods_rec.location.url.dateLastAccessed.should == ["something"]
          end
        end # attributes
        it "should have array with empty string for single empty url element" do
          @mods_rec.from_str(@empty_loc_url).location.url.map { |n| n.text }.should == [""]
        end
      end # url child element

      it "holdingSimple child element" do
        xml = "<mods #{@ns_decl}><location>
          	<physicalLocation authority='marcorg'>MnRM</physicalLocation>
          	<holdingSimple>
          	  	<copyInformation>
          	  	  	<sublocation>Patient reading room</sublocation>
          	  	  	<shelfLocator>QH511.A1J68</shelfLocator>
          	  	  	<enumerationAndChronology unitType='1'> v.1-v.8 1970-1976</enumerationAndChronology>
          	  	</copyInformation>
          	</holdingSimple></location></mods>"
        @mods_rec.from_str(xml).location.holdingSimple.should be_an_instance_of(Nokogiri::XML::NodeSet)
        @mods_rec.from_str(xml).location.holdingSimple.first.should be_an_instance_of(Nokogiri::XML::Element)
      end
      it "holdingComplex child element" do
        xml = "<mods #{@ns_decl}>
        <location>
        <physicalLocation>Menlo Park Public Library</physicalLocation> 	 
          	<holdingExternal> 	 
          	<holding xmlns:iso20775='info:ofi/fmt:xml:xsd:iso20775' xsi:schemaLocation='info:ofi/fmt:xml:xsd:iso20775 http://www.loc.gov/standards/iso20775/N130_ISOholdings_v6_1.xsd'> 	 
          	  	<institutionIdentifier> 	  	 
          	  	<value>JRF</value> 	  	 
          	  	<typeOrSource> 	  	 
          	  	  	<pointer>http://worldcat.org/registry/institutions/</pointer> 	 
          	  	</typeOrSource> 	  	 
          	  	</institutionIdentifier> 	  	 
          	  	  	<physicalLocation>Menlo Park Public Library</physicalLocation> 	  	 
          	  	  	<physicalAddress> 	  	  	 
          	  	  	<text>Menlo Park, CA 94025 United States </text> 	  	 
          	  	  	  	</physicalAddress> 	  	 
          	  	  	  	  	<electronicAddress> 	  	 
          	  	  	  	  	<text>http://www.worldcat.org/wcpa/oclc/15550774? page=frame&amp;url=%3D%3FUTF-8%3FB%FaHR0cDovL2NhdGFsb2cucGxzaW5mby5vcmcvc2VhcmNoL2kwMTk1MDM4NjMw%3F%3D&amp;title=Menlo+Park+Public+Library&amp;linktype=opac&amp;detail=JRF%3AMenlo+Park+Public+Library%3APublic&amp;app=wcapi&amp;id=OCL-OCLC+Staff+use</text>
          	  	  	  	  	</electronicAddress> 	  	  	 
          	  	  	  	  	<holdingSimple> 	  	  	 
          	  	  	  	  	  	<copiesSummary> 	  	  	 
          	  	  	  	  	  	  	<copiesCount>1</copiesCount> 	  	  	 
          	  	  	  	  	  	</copiesSummary> 	  	  	 
          	  	  	  	</holdingSimple> 	  	  	 
          	  	</holding> 	  	  	 
          	  	  	  	</holdingExternal>
            </mods>"
        @mods_rec.from_str(xml).location.holdingExternal.should be_an_instance_of(Nokogiri::XML::NodeSet)
        @mods_rec.from_str(xml).location.holdingExternal.first.should be_an_instance_of(Nokogiri::XML::Element)
      end

    end # WITH namespaces
    
    context "WITHOUT namespaces" do
      before(:all) do
        @url_and_phys = '<mods><location>
                    <url displayLabel="Digital collection of 46 images available online" usage="primary display">http://searchworks.stanford.edu/?f%5Bcollection%5D%5B%5D=The+Reid+W.+Dennis+Collection+of+California+Lithographs&amp;view=gallery</url>
                  </location><location>
                    <physicalLocation>Department of Special Collections, Stanford University Libraries, Stanford, CA 94305.</physicalLocation>
                  </location></mods>'
        # from http://www.loc.gov/standards/mods/v3/mods-userguide-elements.html !!
        #  sublocation is not allowed directly under location
        @incorrect = '<mods><location>
                        	<physicalLocation>Library of Congress </physicalLocation>
                        	<sublocation>Prints and Photographs Division Washington, D.C. 20540 USA</sublocation>
                        	<shelfLocator>DAG no. 1410</shelfLocator>
                      </location></mods>'
      end
      
      context "physicalLocation child element" do
        before(:all) do
          @phys_loc_only = '<mods><location><physicalLocation>here</physicalLocation></location></mods>'
          @phys_loc_authority = '<mods><location><physicalLocation authority="marcorg">MnRM</physicalLocation></location></mods>'
        end
        it "should have access to text value of element" do
          @mods_rec.from_str(@phys_loc_only, false)
          @mods_rec.location.physicalLocation.text.should == "here"
          @mods_rec.from_str(@phys_loc_authority, false)
          @mods_rec.location.physicalLocation.map { |n| n.text }.should == ["MnRM"]
        end
        it "should recognize authority attribute" do
          @mods_rec.from_str(@phys_loc_authority, false)
          @mods_rec.location.physicalLocation.authority.should == ["marcorg"]
        end
        it "should recognize displayLabel attribute" do
          @mods_rec.from_str('<mods><location><physicalLocation displayLabel="Correspondence">some address</physicalLocation></location></mods>', false)
          @mods_rec.location.physicalLocation.displayLabel.should == ["Correspondence"]
        end      
      end

      it "shelfLocator child element" do
        shelf_loc = '<mods><location>
                        	<physicalLocation>Library of Congress </physicalLocation>
                        	<shelfLocator>DAG no. 1410</shelfLocator>
                      </location></mods>'
        @mods_rec.from_str(shelf_loc, false)
        @mods_rec.location.shelfLocator.map { |n| n.text }.should == ["DAG no. 1410"]
      end

      context "url child element" do
        before(:all) do
          @empty_loc_url = '<mods><location><url/></location></mods>'
          @mult_flavor_loc_urls = '<mods><location>
                    	<url access="preview">http://preview.org</url>
                    	<url access="object in context">http://context.org</url>
                    	<url access="raw object">http://object.org</url>
                  </location></mods>'
        end
        it "should have access to text value of element" do
          urls = @mods_rec.from_str(@mult_flavor_loc_urls, false).location.url.map { |e| e.text }
          urls.size.should == 3
          urls.should include("http://preview.org")
          urls.should include("http://context.org")
          urls.should include("http://object.org")
        end
        context "attributes" do
          before(:all) do
            @url_attribs = '<mods><location>
                        <url displayLabel="Digital collection of 46 images available online" usage="primary display">http://searchworks.stanford.edu/?f%5Bcollection%5D%5B%5D=The+Reid+W.+Dennis+Collection+of+California+Lithographs&amp;view=gallery</url>
                      </location></mods>'
          end
          it "should recognize displayLabel attribute" do
            @mods_rec.from_str(@url_attribs, false).location.url.displayLabel.should == ["Digital collection of 46 images available online"]
          end
          it "should recognize access attribute" do
            vals = @mods_rec.from_str(@mult_flavor_loc_urls, false).location.url.access
            vals.size.should == 3
            vals.should include("preview")
            vals.should include("object in context")
            vals.should include("raw object")
          end
          it "should recognize usage attribute" do
            @mods_rec.from_str(@url_attribs, false).location.url.usage.should == ["primary display"]
          end
          it "should recognize note attribute" do
            @mods_rec.from_str('<mods><location><url note="something">http://somewhere.org</url></location></mods>', false)
            @mods_rec.location.url.note.should == ["something"]
          end
          it "should recognize dateLastAccessed attribute" do
            @mods_rec.from_str('<mods><location><url dateLastAccessed="something">http://somewhere.org</url></location></mods>', false)
            @mods_rec.location.url.dateLastAccessed.should == ["something"]
          end
        end # attributes
        it "should have array with empty string for single empty url element" do
          @mods_rec.from_str(@empty_loc_url, false).location.url.map { |n| n.text }.should == [""]
        end
      end # url child element

      it "holdingSimple child element" do
        xml = '<mods><location>
          	<physicalLocation authority="marcorg">MnRM</physicalLocation>
          	<holdingSimple>
          	  	<copyInformation>
          	  	  	<sublocation>Patient reading room</sublocation>
          	  	  	<shelfLocator>QH511.A1J68</shelfLocator>
          	  	  	<enumerationAndChronology unitType="1"> v.1-v.8 1970-1976</enumerationAndChronology>
          	  	</copyInformation>
          	</holdingSimple></location></mods>'
        @mods_rec.from_str(xml, false).location.holdingSimple.should be_an_instance_of(Nokogiri::XML::NodeSet)
        @mods_rec.from_str(xml, false).location.holdingSimple.first.should be_an_instance_of(Nokogiri::XML::Element)
      end
      it "holdingComplex child element" do
        xml = '<mods>
        <location>
        <physicalLocation>Menlo Park Public Library</physicalLocation> 	 
          	<holdingExternal> 	 
          	<holding xmlns:iso20775="info:ofi/fmt:xml:xsd:iso20775" xsi:schemaLocation="info:ofi/fmt:xml:xsd:iso20775 http://www.loc.gov/standards/iso20775/N130_ISOholdings_v6_1.xsd"> 	 
          	  	<institutionIdentifier> 	  	 
          	  	<value>JRF</value> 	  	 
          	  	<typeOrSource> 	  	 
          	  	  	<pointer>http://worldcat.org/registry/institutions/</pointer> 	 
          	  	</typeOrSource> 	  	 
          	  	</institutionIdentifier> 	  	 
          	  	  	<physicalLocation>Menlo Park Public Library</physicalLocation> 	  	 
          	  	  	<physicalAddress> 	  	  	 
          	  	  	<text>Menlo Park, CA 94025 United States </text> 	  	 
          	  	  	  	</physicalAddress> 	  	 
          	  	  	  	  	<electronicAddress> 	  	 
          	  	  	  	  	<text>http://www.worldcat.org/wcpa/oclc/15550774? page=frame&amp;url=%3D%3FUTF-8%3FB%FaHR0cDovL2NhdGFsb2cucGxzaW5mby5vcmcvc2VhcmNoL2kwMTk1MDM4NjMw%3F%3D&amp;title=Menlo+Park+Public+Library&amp;linktype=opac&amp;detail=JRF%3AMenlo+Park+Public+Library%3APublic&amp;app=wcapi&amp;id=OCL-OCLC+Staff+use</text>
          	  	  	  	  	</electronicAddress> 	  	  	 
          	  	  	  	  	<holdingSimple> 	  	  	 
          	  	  	  	  	  	<copiesSummary> 	  	  	 
          	  	  	  	  	  	  	<copiesCount>1</copiesCount> 	  	  	 
          	  	  	  	  	  	</copiesSummary> 	  	  	 
          	  	  	  	</holdingSimple> 	  	  	 
          	  	</holding> 	  	  	 
          	  	  	  	</holdingExternal>
            </mods>'
        @mods_rec.from_str(xml, false).location.holdingExternal.should be_an_instance_of(Nokogiri::XML::NodeSet)
        @mods_rec.from_str(xml, false).location.holdingExternal.first.should be_an_instance_of(Nokogiri::XML::Element)
      end

    end # WITHOUT namespaces

  end

end