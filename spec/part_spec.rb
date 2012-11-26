require 'spec_helper'

describe "Mods <part> Element" do
  before(:all) do
    @mods_rec = Mods::Record.new
    @ns_decl = "xmlns='#{Mods::MODS_NS}'"
  end

  it "should normalize dates" do
    pending "to be implemented"
  end
  
  context "basic <part> terminology pieces" do
    
    context "WITH namespaces" do
      before(:all) do
        @ex = @mods_rec.from_str("<mods #{@ns_decl}><part>
                	<detail>
                	  	<title>Wayfarers (Poem)</title>
                	</detail>
                	<extent unit='pages'>
                	  	<start>97</start>
                	  	<end>98</end>
                	</extent>
              </part></mods>").part
        @ex2 = @mods_rec.from_str("<mods #{@ns_decl}><part>
                	<detail type='page number'>
                	  	<number>3</number>
                	</detail>
                	<extent unit='pages'>
                	  	<start>3</start>
                	</extent>
              </part></mods>").part
        @detail = @mods_rec.from_str("<mods #{@ns_decl}><part>
                  <detail type='issue'>
                      <number>1</number>
                      <caption>no.</caption>
                  </detail>
              </part></mods>").part
      end
      
      it "should be a NodeSet" do
        [@ex, @ex2, @detail].each { |p| p.should be_an_instance_of(Nokogiri::XML::NodeSet) }
      end
      it "should have as many members as there are <part> elements in the xml" do
        [@ex, @ex2, @detail].each { |p| p.size.should == 1 }
      end
      it "should recognize type(_at) attribute on <part> element" do
        @mods_rec.from_str("<mods #{@ns_decl}><part type='val'>anything</part></mods>")
        @mods_rec.part.type_at.should == ['val']
      end
      it "should recognize order attribute on <part> element" do
        @mods_rec.from_str("<mods #{@ns_decl}><part order='val'>anything</part></mods>")
        @mods_rec.part.order.should == ['val']
      end
      it "should recognize ID attribute on <part> element as id_at term" do
        @mods_rec.from_str("<mods #{@ns_decl}><part ID='val'>anything</part></mods>")
        @mods_rec.part.id_at.should == ['val']
      end

      context "<detail> child element" do
        it "should be a NodeSet" do
          [@ex, @ex2, @detail].each { |p| p.detail.should be_an_instance_of(Nokogiri::XML::NodeSet) }
        end
        it "detail NodeSet should have as many Nodes as there are <detail> elements in the xml" do
          [@ex, @ex2, @detail].each { |p| p.detail.size.should == 1 }
        end
        it "should recognize type(_at) attribute on <detail> element" do
          @ex2.detail.type_at.should == ['page number']
          @detail.detail.type_at.should == ['issue']
        end
        it "should recognize level attribute on <detail> element" do
          @mods_rec.from_str("<mods #{@ns_decl}><part><detail level='val'>anything</detail></part></mods>")
          @mods_rec.part.detail.level.should == ['val']
        end
        context "<number> child element" do
          it "should be a NodeSet" do
            [@ex, @ex2, @detail].each { |p| p.detail.number.should be_an_instance_of(Nokogiri::XML::NodeSet) }
          end
          it "number NodeSet should have as many Nodes as there are <number> elements in the xml" do
            [@ex2, @detail].each { |p| p.detail.number.size.should == 1 }
            @ex.detail.number.size.should == 0
          end
          it "text should get element value" do
            @ex2.detail.number.map { |n| n.text }.should == ['3']
            @detail.detail.number.map { |n| n.text }.should == ['1']
          end
        end # <number>
        context "<caption> child element" do
          before(:all) do
            @mods_rec.from_str("<mods #{@ns_decl}><part><detail><caption>anything</caption></detail></part></mods>")
            @caption = @mods_rec.part.detail.caption
          end
          it "should be a NodeSet" do
            [@ex, @ex2, @detail].each { |p| p.detail.caption.should be_an_instance_of(Nokogiri::XML::NodeSet) }
            @caption.should be_an_instance_of(Nokogiri::XML::NodeSet)
          end
          it "caption NodeSet should have as many Nodes as there are <caption> elements in the xml" do
            [@ex, @ex2].each { |p| p.detail.caption.size.should == 0 }
            @detail.detail.caption.size.should == 1
            @caption.size.should == 1
          end
          it "text should get element value" do
            @detail.detail.caption.map { |n| n.text }.should == ['no.']
            @caption.map { |n| n.text }.should == ['anything']
          end
        end # <caption>
        context "<title> child element" do
          it "should be a NodeSet" do
            [@ex, @ex2, @detail].each { |p| p.detail.title.should be_an_instance_of(Nokogiri::XML::NodeSet) }
          end
          it "title NodeSet should have as many Nodes as there are <title> elements in the xml" do
            @ex.detail.title.size.should == 1
            [@ex2, @detail].each { |p| p.detail.title.size.should == 0 }
          end
          it "text should get element value" do
            @ex.detail.title.map { |n| n.text }.should == ['Wayfarers (Poem)']
            [@ex2, @detail].each { |p| p.detail.title.map { |n| n.text }.should == [] }
          end
        end # <title>
      end # <detail>

      context "<extent> child element" do
        it "should be a NodeSet" do
          [@ex, @ex2, @detail].each { |p| p.extent.should be_an_instance_of(Nokogiri::XML::NodeSet) }
        end
        it "extent NodeSet should have as many Nodes as there are <extent> elements in the xml" do
          [@ex, @ex2].each { |p| p.extent.size.should == 1 }
          @detail.extent.size.should == 0
        end
        it "should recognize unit attribute on <extent> element" do
          [@ex, @ex2].each { |p| p.extent.unit.should == ['pages'] }
        end
        context "<start> child element" do
          it "should be a NodeSet" do
            [@ex, @ex2, @detail].each { |p| p.extent.start.should be_an_instance_of(Nokogiri::XML::NodeSet) }
          end
          it "start NodeSet should have as many Nodes as there are <start> elements in the xml" do
            [@ex, @ex2].each { |p| p.extent.start.size.should == 1 }
            @detail.extent.start.size.should == 0
          end
          it "text should get element value" do
            @ex.extent.start.map { |n| n.text }.should == ['97']
            @ex2.extent.start.map { |n| n.text }.should == ['3']
          end
        end # <start>
        context "<end> child element" do
          it "should be a NodeSet" do
            [@ex, @ex2, @detail].each { |p| p.extent.end.should be_an_instance_of(Nokogiri::XML::NodeSet) }
          end
          it "end NodeSet should have as many Nodes as there are <end> elements in the xml" do
            @ex.extent.end.size.should == 1
            [@ex2, @detail].each { |p| p.extent.end.size.should == 0 }
          end
          it "text should get element value" do
            @ex.extent.end.map { |n| n.text }.should == ['98']
          end
        end # <end>
        context "<total> child element" do
          before(:all) do
            @mods_rec.from_str("<mods #{@ns_decl}><part><extent><total>anything</total></extent></part></mods>")
            @total = @mods_rec.part.extent.total
          end
          it "should be a NodeSet" do
            [@ex, @ex2, @detail].each { |p| p.extent.total.should be_an_instance_of(Nokogiri::XML::NodeSet) }
            @total.should be_an_instance_of(Nokogiri::XML::NodeSet)
          end
          it "total NodeSet should have as many Nodes as there are <total> elements in the xml" do
            [@ex, @ex2, @detail].each { |p| p.extent.total.size.should == 0 }
            @total.size.should == 1
          end
          it "text should get element value" do
            @total.map { |n| n.text }.should == ['anything']
          end
        end # <total>
        context "<list> child element" do
          before(:all) do
            @mods_rec.from_str("<mods #{@ns_decl}><part><extent><list>anything</list></extent></part></mods>")
            @list = @mods_rec.part.extent.list
          end
          it "should be a NodeSet" do
            [@ex, @ex2, @detail].each { |p| p.extent.list.should be_an_instance_of(Nokogiri::XML::NodeSet) }
            @list.should be_an_instance_of(Nokogiri::XML::NodeSet)
          end
          it "list NodeSet should have as many Nodes as there are <list> elements in the xml" do
            [@ex, @ex2, @detail].each { |p| p.extent.list.size.should == 0 }
            @list.size.should == 1
          end
          it "text should get element value" do
            @list.map { |n| n.text }.should == ['anything']
          end
        end # <list>
      end # <extent>

      context "<date> child element" do
        before(:all) do
          @date = @mods_rec.from_str("<mods #{@ns_decl}><part><date encoding='w3cdtf'>1999</date></part></mods>").part.date
        end
        it "should be a NodeSet" do
          [@ex, @ex2, @detail].each { |p| p.date.should be_an_instance_of(Nokogiri::XML::NodeSet) }
          @date.should be_an_instance_of(Nokogiri::XML::NodeSet)
        end
        it "extent NodeSet should have as many Nodes as there are <extent> elements in the xml" do
          [@ex, @ex2, @detail].each { |p| p.date.size.should == 0 }
          @date.size.should == 1
        end
        it "should recognize all date attributes except keyDate" do
          Mods::DATE_ATTRIBS.reject { |n| n == 'keyDate' }.each { |a|  
            @mods_rec.from_str("<mods #{@ns_decl}><part><date #{a}='attr_val'>zzz</date></part></mods>")
            @mods_rec.part.date.send(a.to_sym).should == ['attr_val']
          }
        end
        it "should not recognize keyDate attribute" do
          @mods_rec.from_str("<mods #{@ns_decl}><part><date keyDate='yes'>zzz</date></part></mods>")
          expect { @mods_rec.part.date.keyDate }.to raise_error(NoMethodError, /undefined method.*keyDate/)
        end
      end # <date>

      context "<text> child element as .text_el term" do
        before(:all) do
          @text_ns = @mods_rec.from_str("<mods #{@ns_decl}><part><text encoding='w3cdtf'>1999</text></part></mods>").part.text_el
        end
        it "should be a NodeSet" do
          [@ex, @ex2, @detail].each { |p| p.text_el.should be_an_instance_of(Nokogiri::XML::NodeSet) }
          @text_ns.should be_an_instance_of(Nokogiri::XML::NodeSet)
        end
        it "text_el NodeSet should have as many Nodes as there are <text> elements in the xml" do
          [@ex, @ex2, @detail].each { |p| p.text_el.size.should == 0 }
          @text_ns.size.should == 1
        end
        it "should recognize displayLabel attribute" do
          @mods_rec.from_str("<mods #{@ns_decl}><part><text displayLabel='foo'>zzz</text></part></mods>")
          @mods_rec.part.text_el.displayLabel.should == ['foo']
        end
        it "should recognize type(_at) attribute on <text> element" do
          @mods_rec.from_str("<mods #{@ns_decl}><part><text type='bar'>anything</text></part></mods>")
          @mods_rec.part.text_el.type_at.should == ['bar']
        end
      end # <text>
    end # WITH namespaces

    context "WITHOUT namespaces" do
      before(:all) do
        @ex = @mods_rec.from_str("<mods><part>
                	<detail>
                	  	<title>Wayfarers (Poem)</title>
                	</detail>
                	<extent unit='pages'>
                	  	<start>97</start>
                	  	<end>98</end>
                	</extent>
              </part></mods>", false).part
        @ex2 = @mods_rec.from_str("<mods><part>
                	<detail type='page number'>
                	  	<number>3</number>
                	</detail>
                	<extent unit='pages'>
                	  	<start>3</start>
                	</extent>
              </part></mods>", false).part
        @detail = @mods_rec.from_str("<mods><part>
                  <detail type='issue'>
                      <number>1</number>
                      <caption>no.</caption>
                  </detail>
              </part></mods>", false).part
      end
      
      it "should be a NodeSet" do
        [@ex, @ex2, @detail].each { |p| p.should be_an_instance_of(Nokogiri::XML::NodeSet) }
      end
      it "should have as many members as there are <part> elements in the xml" do
        [@ex, @ex2, @detail].each { |p| p.size.should == 1 }
      end
      it "should recognize type(_at) attribute on <part> element" do
        @mods_rec.from_str("<mods><part type='val'>anything</part></mods>", false)
        @mods_rec.part.type_at.should == ['val']
      end
      it "should recognize order attribute on <part> element" do
        @mods_rec.from_str("<mods><part order='val'>anything</part></mods>", false)
        @mods_rec.part.order.should == ['val']
      end
      it "should recognize ID attribute on <part> element as id_at term" do
        @mods_rec.from_str("<mods><part ID='val'>anything</part></mods>", false)
        @mods_rec.part.id_at.should == ['val']
      end

      context "<detail> child element" do
        it "should be a NodeSet" do
          [@ex, @ex2, @detail].each { |p| p.detail.should be_an_instance_of(Nokogiri::XML::NodeSet) }
        end
        it "detail NodeSet should have as many Nodes as there are <detail> elements in the xml" do
          [@ex, @ex2, @detail].each { |p| p.detail.size.should == 1 }
        end
        it "should recognize type(_at) attribute on <detail> element" do
          @ex2.detail.type_at.should == ['page number']
          @detail.detail.type_at.should == ['issue']
        end
        it "should recognize level attribute on <detail> element" do
          @mods_rec.from_str("<mods><part><detail level='val'>anything</detail></part></mods>", false)
          @mods_rec.part.detail.level.should == ['val']
        end
        context "<number> child element" do
          it "should be a NodeSet" do
            [@ex, @ex2, @detail].each { |p| p.detail.number.should be_an_instance_of(Nokogiri::XML::NodeSet) }
          end
          it "number NodeSet should have as many Nodes as there are <number> elements in the xml" do
            [@ex2, @detail].each { |p| p.detail.number.size.should == 1 }
            @ex.detail.number.size.should == 0
          end
          it "text should get element value" do
            @ex2.detail.number.map { |n| n.text }.should == ['3']
            @detail.detail.number.map { |n| n.text }.should == ['1']
          end
        end # <number>
        context "<caption> child element" do
          before(:all) do
            @mods_rec.from_str("<mods><part><detail><caption>anything</caption></detail></part></mods>", false)
            @caption = @mods_rec.part.detail.caption
          end
          it "should be a NodeSet" do
            [@ex, @ex2, @detail].each { |p| p.detail.caption.should be_an_instance_of(Nokogiri::XML::NodeSet) }
            @caption.should be_an_instance_of(Nokogiri::XML::NodeSet)
          end
          it "caption NodeSet should have as many Nodes as there are <caption> elements in the xml" do
            [@ex, @ex2].each { |p| p.detail.caption.size.should == 0 }
            @detail.detail.caption.size.should == 1
            @caption.size.should == 1
          end
          it "text should get element value" do
            @detail.detail.caption.map { |n| n.text }.should == ['no.']
            @caption.map { |n| n.text }.should == ['anything']
          end
        end # <caption>
        context "<title> child element" do
          it "should be a NodeSet" do
            [@ex, @ex2, @detail].each { |p| p.detail.title.should be_an_instance_of(Nokogiri::XML::NodeSet) }
          end
          it "title NodeSet should have as many Nodes as there are <title> elements in the xml" do
            @ex.detail.title.size.should == 1
            [@ex2, @detail].each { |p| p.detail.title.size.should == 0 }
          end
          it "text should get element value" do
            @ex.detail.title.map { |n| n.text }.should == ['Wayfarers (Poem)']
            [@ex2, @detail].each { |p| p.detail.title.map { |n| n.text }.should == [] }
          end
        end # <title>
      end # <detail>

      context "<extent> child element" do
        it "should be a NodeSet" do
          [@ex, @ex2, @detail].each { |p| p.extent.should be_an_instance_of(Nokogiri::XML::NodeSet) }
        end
        it "extent NodeSet should have as many Nodes as there are <extent> elements in the xml" do
          [@ex, @ex2].each { |p| p.extent.size.should == 1 }
          @detail.extent.size.should == 0
        end
        it "should recognize unit attribute on <extent> element" do
          [@ex, @ex2].each { |p| p.extent.unit.should == ['pages'] }
        end
        context "<start> child element" do
          it "should be a NodeSet" do
            [@ex, @ex2, @detail].each { |p| p.extent.start.should be_an_instance_of(Nokogiri::XML::NodeSet) }
          end
          it "start NodeSet should have as many Nodes as there are <start> elements in the xml" do
            [@ex, @ex2].each { |p| p.extent.start.size.should == 1 }
            @detail.extent.start.size.should == 0
          end
          it "text should get element value" do
            @ex.extent.start.map { |n| n.text }.should == ['97']
            @ex2.extent.start.map { |n| n.text }.should == ['3']
          end
        end # <start>
        context "<end> child element" do
          it "should be a NodeSet" do
            [@ex, @ex2, @detail].each { |p| p.extent.end.should be_an_instance_of(Nokogiri::XML::NodeSet) }
          end
          it "end NodeSet should have as many Nodes as there are <end> elements in the xml" do
            @ex.extent.end.size.should == 1
            [@ex2, @detail].each { |p| p.extent.end.size.should == 0 }
          end
          it "text should get element value" do
            @ex.extent.end.map { |n| n.text }.should == ['98']
          end
        end # <end>
        context "<total> child element" do
          before(:all) do
            @mods_rec.from_str("<mods><part><extent><total>anything</total></extent></part></mods>", false)
            @total = @mods_rec.part.extent.total
          end
          it "should be a NodeSet" do
            [@ex, @ex2, @detail].each { |p| p.extent.total.should be_an_instance_of(Nokogiri::XML::NodeSet) }
            @total.should be_an_instance_of(Nokogiri::XML::NodeSet)
          end
          it "total NodeSet should have as many Nodes as there are <total> elements in the xml" do
            [@ex, @ex2, @detail].each { |p| p.extent.total.size.should == 0 }
            @total.size.should == 1
          end
          it "text should get element value" do
            @total.map { |n| n.text }.should == ['anything']
          end
        end # <total>
        context "<list> child element" do
          before(:all) do
            @mods_rec.from_str("<mods><part><extent><list>anything</list></extent></part></mods>", false)
            @list = @mods_rec.part.extent.list
          end
          it "should be a NodeSet" do
            [@ex, @ex2, @detail].each { |p| p.extent.list.should be_an_instance_of(Nokogiri::XML::NodeSet) }
            @list.should be_an_instance_of(Nokogiri::XML::NodeSet)
          end
          it "list NodeSet should have as many Nodes as there are <list> elements in the xml" do
            [@ex, @ex2, @detail].each { |p| p.extent.list.size.should == 0 }
            @list.size.should == 1
          end
          it "text should get element value" do
            @list.map { |n| n.text }.should == ['anything']
          end
        end # <list>
      end # <extent>

      context "<date> child element" do
        before(:all) do
          @date = @mods_rec.from_str("<mods><part><date encoding='w3cdtf'>1999</date></part></mods>", false).part.date
        end
        it "should be a NodeSet" do
          [@ex, @ex2, @detail].each { |p| p.date.should be_an_instance_of(Nokogiri::XML::NodeSet) }
          @date.should be_an_instance_of(Nokogiri::XML::NodeSet)
        end
        it "extent NodeSet should have as many Nodes as there are <extent> elements in the xml" do
          [@ex, @ex2, @detail].each { |p| p.date.size.should == 0 }
          @date.size.should == 1
        end
        it "should recognize all date attributes except keyDate" do
          Mods::DATE_ATTRIBS.reject { |n| n == 'keyDate' }.each { |a|  
            @mods_rec.from_str("<mods><part><date #{a}='attr_val'>zzz</date></part></mods>", false)
            @mods_rec.part.date.send(a.to_sym).should == ['attr_val']
          }
        end
        it "should not recognize keyDate attribute" do
          @mods_rec.from_str("<mods><part><date keyDate='yes'>zzz</date></part></mods>", false)
          expect { @mods_rec.part.date.keyDate }.to raise_error(NoMethodError, /undefined method.*keyDate/)
        end
      end # <date>

      context "<text> child element as .text_el term" do
        before(:all) do
          @text_ns = @mods_rec.from_str("<mods><part><text encoding='w3cdtf'>1999</text></part></mods>", false).part.text_el
        end
        it "should be a NodeSet" do
          [@ex, @ex2, @detail].each { |p| p.text_el.should be_an_instance_of(Nokogiri::XML::NodeSet) }
          @text_ns.should be_an_instance_of(Nokogiri::XML::NodeSet)
        end
        it "text_el NodeSet should have as many Nodes as there are <text> elements in the xml" do
          [@ex, @ex2, @detail].each { |p| p.text_el.size.should == 0 }
          @text_ns.size.should == 1
        end
        it "should recognize displayLabel attribute" do
          @mods_rec.from_str("<mods><part><text displayLabel='foo'>zzz</text></part></mods>", false)
          @mods_rec.part.text_el.displayLabel.should == ['foo']
        end
        it "should recognize type(_at) attribute on <text> element" do
          @mods_rec.from_str("<mods><part><text type='bar'>anything</text></part></mods>", false)
          @mods_rec.part.text_el.type_at.should == ['bar']
        end
      end # <text>
    end # WITHOUT namespaces


  end # basic <part> terminoology
end