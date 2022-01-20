require 'spec_helper'

describe "Mods <part> Element" do
  before(:all) do
    @mods_rec = Mods::Record.new
    @ns_decl = "xmlns='#{Mods::MODS_NS}'"
  end

  it "should normalize dates" do
    skip "to be implemented"
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
        [@ex, @ex2, @detail].each { |p| expect(p).to be_an_instance_of(Nokogiri::XML::NodeSet) }
      end
      it "should have as many members as there are <part> elements in the xml" do
        [@ex, @ex2, @detail].each { |p| expect(p.size).to eq(1) }
      end
      it "should recognize type(_at) attribute on <part> element" do
        @mods_rec.from_str("<mods #{@ns_decl}><part type='val'>anything</part></mods>")
        expect(@mods_rec.part.type_at).to eq(['val'])
      end
      it "should recognize order attribute on <part> element" do
        @mods_rec.from_str("<mods #{@ns_decl}><part order='val'>anything</part></mods>")
        expect(@mods_rec.part.order).to eq(['val'])
      end
      it "should recognize ID attribute on <part> element as id_at term" do
        @mods_rec.from_str("<mods #{@ns_decl}><part ID='val'>anything</part></mods>")
        expect(@mods_rec.part.id_at).to eq(['val'])
      end

      context "<detail> child element" do
        it "should be a NodeSet" do
          [@ex, @ex2, @detail].each { |p| expect(p.detail).to be_an_instance_of(Nokogiri::XML::NodeSet) }
        end
        it "detail NodeSet should have as many Nodes as there are <detail> elements in the xml" do
          [@ex, @ex2, @detail].each { |p| expect(p.detail.size).to eq(1) }
        end
        it "should recognize type(_at) attribute on <detail> element" do
          expect(@ex2.detail.type_at).to eq(['page number'])
          expect(@detail.detail.type_at).to eq(['issue'])
        end
        it "should recognize level attribute on <detail> element" do
          @mods_rec.from_str("<mods #{@ns_decl}><part><detail level='val'>anything</detail></part></mods>")
          expect(@mods_rec.part.detail.level).to eq(['val'])
        end
        context "<number> child element" do
          it "should be a NodeSet" do
            [@ex, @ex2, @detail].each { |p| expect(p.detail.number).to be_an_instance_of(Nokogiri::XML::NodeSet) }
          end
          it "number NodeSet should have as many Nodes as there are <number> elements in the xml" do
            [@ex2, @detail].each { |p| expect(p.detail.number.size).to eq(1) }
            expect(@ex.detail.number.size).to eq(0)
          end
          it "text should get element value" do
            expect(@ex2.detail.number.map { |n| n.text }).to eq(['3'])
            expect(@detail.detail.number.map { |n| n.text }).to eq(['1'])
          end
        end # <number>
        context "<caption> child element" do
          before(:all) do
            @mods_rec.from_str("<mods #{@ns_decl}><part><detail><caption>anything</caption></detail></part></mods>")
            @caption = @mods_rec.part.detail.caption
          end
          it "should be a NodeSet" do
            [@ex, @ex2, @detail].each { |p| expect(p.detail.caption).to be_an_instance_of(Nokogiri::XML::NodeSet) }
            expect(@caption).to be_an_instance_of(Nokogiri::XML::NodeSet)
          end
          it "caption NodeSet should have as many Nodes as there are <caption> elements in the xml" do
            [@ex, @ex2].each { |p| expect(p.detail.caption.size).to eq(0) }
            expect(@detail.detail.caption.size).to eq(1)
            expect(@caption.size).to eq(1)
          end
          it "text should get element value" do
            expect(@detail.detail.caption.map { |n| n.text }).to eq(['no.'])
            expect(@caption.map { |n| n.text }).to eq(['anything'])
          end
        end # <caption>
        context "<title> child element" do
          it "should be a NodeSet" do
            [@ex, @ex2, @detail].each { |p| expect(p.detail.title).to be_an_instance_of(Nokogiri::XML::NodeSet) }
          end
          it "title NodeSet should have as many Nodes as there are <title> elements in the xml" do
            expect(@ex.detail.title.size).to eq(1)
            [@ex2, @detail].each { |p| expect(p.detail.title.size).to eq(0) }
          end
          it "text should get element value" do
            expect(@ex.detail.title.map { |n| n.text }).to eq(['Wayfarers (Poem)'])
            [@ex2, @detail].each { |p| expect(p.detail.title.map { |n| n.text }).to eq([]) }
          end
        end # <title>
      end # <detail>

      context "<extent> child element" do
        it "should be a NodeSet" do
          [@ex, @ex2, @detail].each { |p| expect(p.extent).to be_an_instance_of(Nokogiri::XML::NodeSet) }
        end
        it "extent NodeSet should have as many Nodes as there are <extent> elements in the xml" do
          [@ex, @ex2].each { |p| expect(p.extent.size).to eq(1) }
          expect(@detail.extent.size).to eq(0)
        end
        it "should recognize unit attribute on <extent> element" do
          [@ex, @ex2].each { |p| expect(p.extent.unit).to eq(['pages']) }
        end
        context "<start> child element" do
          it "should be a NodeSet" do
            [@ex, @ex2, @detail].each { |p| expect(p.extent.start).to be_an_instance_of(Nokogiri::XML::NodeSet) }
          end
          it "start NodeSet should have as many Nodes as there are <start> elements in the xml" do
            [@ex, @ex2].each { |p| expect(p.extent.start.size).to eq(1) }
            expect(@detail.extent.start.size).to eq(0)
          end
          it "text should get element value" do
            expect(@ex.extent.start.map { |n| n.text }).to eq(['97'])
            expect(@ex2.extent.start.map { |n| n.text }).to eq(['3'])
          end
        end # <start>
        context "<end> child element" do
          it "should be a NodeSet" do
            [@ex, @ex2, @detail].each { |p| expect(p.extent.end).to be_an_instance_of(Nokogiri::XML::NodeSet) }
          end
          it "end NodeSet should have as many Nodes as there are <end> elements in the xml" do
            expect(@ex.extent.end.size).to eq(1)
            [@ex2, @detail].each { |p| expect(p.extent.end.size).to eq(0) }
          end
          it "text should get element value" do
            expect(@ex.extent.end.map { |n| n.text }).to eq(['98'])
          end
        end # <end>
        context "<total> child element" do
          before(:all) do
            @mods_rec.from_str("<mods #{@ns_decl}><part><extent><total>anything</total></extent></part></mods>")
            @total = @mods_rec.part.extent.total
          end
          it "should be a NodeSet" do
            [@ex, @ex2, @detail].each { |p| expect(p.extent.total).to be_an_instance_of(Nokogiri::XML::NodeSet) }
            expect(@total).to be_an_instance_of(Nokogiri::XML::NodeSet)
          end
          it "total NodeSet should have as many Nodes as there are <total> elements in the xml" do
            [@ex, @ex2, @detail].each { |p| expect(p.extent.total.size).to eq(0) }
            expect(@total.size).to eq(1)
          end
          it "text should get element value" do
            expect(@total.map { |n| n.text }).to eq(['anything'])
          end
        end # <total>
        context "<list> child element" do
          before(:all) do
            @mods_rec.from_str("<mods #{@ns_decl}><part><extent><list>anything</list></extent></part></mods>")
            @list = @mods_rec.part.extent.list
          end
          it "should be a NodeSet" do
            [@ex, @ex2, @detail].each { |p| expect(p.extent.list).to be_an_instance_of(Nokogiri::XML::NodeSet) }
            expect(@list).to be_an_instance_of(Nokogiri::XML::NodeSet)
          end
          it "list NodeSet should have as many Nodes as there are <list> elements in the xml" do
            [@ex, @ex2, @detail].each { |p| expect(p.extent.list.size).to eq(0) }
            expect(@list.size).to eq(1)
          end
          it "text should get element value" do
            expect(@list.map { |n| n.text }).to eq(['anything'])
          end
        end # <list>
      end # <extent>

      context "<date> child element" do
        before(:all) do
          @date = @mods_rec.from_str("<mods #{@ns_decl}><part><date encoding='w3cdtf'>1999</date></part></mods>").part.date
        end
        it "should be a NodeSet" do
          [@ex, @ex2, @detail].each { |p| expect(p.date).to be_an_instance_of(Nokogiri::XML::NodeSet) }
          expect(@date).to be_an_instance_of(Nokogiri::XML::NodeSet)
        end
        it "extent NodeSet should have as many Nodes as there are <extent> elements in the xml" do
          [@ex, @ex2, @detail].each { |p| expect(p.date.size).to eq(0) }
          expect(@date.size).to eq(1)
        end
        it "should recognize all date attributes except keyDate" do
          Mods::DATE_ATTRIBS.reject { |n| n == 'keyDate' }.each { |a|
            @mods_rec.from_str("<mods #{@ns_decl}><part><date #{a}='attr_val'>zzz</date></part></mods>")
            expect(@mods_rec.part.date.send(a.to_sym)).to eq(['attr_val'])
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
          [@ex, @ex2, @detail].each { |p| expect(p.text_el).to be_an_instance_of(Nokogiri::XML::NodeSet) }
          expect(@text_ns).to be_an_instance_of(Nokogiri::XML::NodeSet)
        end
        it "text_el NodeSet should have as many Nodes as there are <text> elements in the xml" do
          [@ex, @ex2, @detail].each { |p| expect(p.text_el.size).to eq(0) }
          expect(@text_ns.size).to eq(1)
        end
        it "should recognize displayLabel attribute" do
          @mods_rec.from_str("<mods #{@ns_decl}><part><text displayLabel='foo'>zzz</text></part></mods>")
          expect(@mods_rec.part.text_el.displayLabel).to eq(['foo'])
        end
        it "should recognize type(_at) attribute on <text> element" do
          @mods_rec.from_str("<mods #{@ns_decl}><part><text type='bar'>anything</text></part></mods>")
          expect(@mods_rec.part.text_el.type_at).to eq(['bar'])
        end
      end # <text>
    end # WITH namespaces
  end # basic <part> terminoology
end
