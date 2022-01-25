require 'spec_helper'

describe "Mods <part> Element" do
  before(:all) do
    @ex = mods_record("<part>
              <detail>
                  <title>Wayfarers (Poem)</title>
              </detail>
              <extent unit='pages'>
                  <start>97</start>
                  <end>98</end>
              </extent>
          </part>").part
    @ex2 = mods_record("<part>
              <detail type='page number'>
                  <number>3</number>
              </detail>
              <extent unit='pages'>
                  <start>3</start>
              </extent>
          </part>").part
    @detail = mods_record("<part>
              <detail type='issue'>
                  <number>1</number>
                  <caption>no.</caption>
              </detail>
          </part>").part
  end

  it "should be a NodeSet" do
    [@ex, @ex2, @detail].each { |p| expect(p).to be_an_instance_of(Nokogiri::XML::NodeSet) }
  end
  it "should have as many members as there are <part> elements in the xml" do
    [@ex, @ex2, @detail].each { |p| expect(p.size).to eq(1) }
  end
  it "should recognize type(_at) attribute on <part> element" do
    record = mods_record("<part type='val'>anything</part>")
    expect(record.part.type_at).to eq(['val'])
  end
  it "should recognize order attribute on <part> element" do
    record = mods_record("<part order='val'>anything</part>")
    expect(record.part.order).to eq(['val'])
  end
  it "should recognize ID attribute on <part> element as id_at term" do
    record = mods_record("<part ID='val'>anything</part>")
    expect(record.part.id_at).to eq(['val'])
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
      record = mods_record("<part><detail level='val'>anything</detail></part>")
      expect(record.part.detail.level).to eq(['val'])
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
        @caption = mods_record('<part><detail><caption>anything</caption></detail></part>').part.detail.caption
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
        record = mods_record("<part><extent><total>anything</total></extent></part>")
        @total = record.part.extent.total
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
        record = mods_record("<part><extent><list>anything</list></extent></part>")
        @list = record.part.extent.list
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
      @date = mods_record("<part><date encoding='w3cdtf'>1999</date></part>").part.date
    end
    it "should recognize all date attributes except keyDate" do
      Mods::DATE_ATTRIBS.reject { |n| n == 'keyDate' }.each { |a|
        record = mods_record("<part><date #{a}='attr_val'>zzz</date></part>")
        expect(record.part.date.send(a.to_sym)).to eq(['attr_val'])
      }
    end
    it "should not recognize keyDate attribute" do
      record = mods_record("<part><date keyDate='yes'>zzz</date></part>")
      expect { record.part.date.keyDate }.to raise_error(NoMethodError, /undefined method.*keyDate/)
    end
  end # <date>

  context "<text> child element as .text_el term" do
    let(:text_ns) do
      mods_record("<part><text type='bar' displayLabel='foo'>1999</text></part>").part.text_el
    end
    it "has text" do
      expect(text_ns).to have_attributes(text: '1999')
    end

    it "recognizes other attributes" do
      expect(text_ns).to have_attributes(displayLabel: ['foo'], type_at: ['bar'])
    end
  end
end
