require 'spec_helper'

describe "Mods Name Elements" do
  
  before(:all) do
    @mods = Mods::Record.new
  end

  context "name element" do
    it "should return an array with a single value when there is a single name element" do
      @mods.from_str('<mods><name><displayForm>Mr. Foo Bar</displayForm></name></mods>')
      @mods.name.should == ["Mr. Foo Bar"]
    end
    it "should return an array of values when there are multiple name elements" do
      s = '<mods><name><displayForm>Mr. Foo Bar</displayForm></name><name><displayForm>Mrs. I. Bert</displayForm></name></mods>'
      @mods.from_str(s)
      @mods.name.should == ["Mr. Foo Bar", "Mrs. I. Bert"]
    end
    it "should allow individual subelements to be accessed" do
      @mods.from_str('<mods><name><displayForm>Mr. Foo Bar</displayForm></name></mods>')
      @mods.name.displayForm.should == ["Mr. Foo Bar"]
    end
    it "should print a warning when there are no subelements" do
      @mods.from_str('<mods><name>tigers</name></mods>')
      pending "to be implemented"
    end
    context "attributes" do
      it "should recognize attributes on name node" do
        Mods::Name::ATTRIBUTES.each { |attrb|  
          @mods.from_str("<mods><name #{attrb}='hello'><displayForm>q</displayForm></name></mods>")
          @mods.name.send(attrb.to_sym).should == ['hello']
        }
      end
      it "should raise NoMethodError for incorrect attributes" do
        @mods.from_str("<mods><name wrong='ignore'><displayForm>q</displayForm></name></mods>")
        expect { @mods.name.wrong }.to raise_error(NoMethodError, /undefined method.*wrong/)
      end
      it "should cope with attributes on a name element that has no subelements" do
        Mods::Name::ATTRIBUTES.each { |attrb|  
          @mods.from_str("<mods><name #{attrb}='hello'>q</name></mods>")
          @mods.name.send(attrb.to_sym).should == 'hello'
        }
      end
    end
  end
  
  context "value for mods.name" do
    it "should prefer displayForm subelement value to concat of namePart subelement values" do
      str =  '<mods><name><displayForm>Mr. Foo Bar</displayForm><namePart>a</namePart><namePart>b</namePart></name></mods>'
      @mods.from_str(str)
      @mods.name.displayForm.should == ["Mr. Foo Bar"]
      @mods.name.should == ["Mr. Foo Bar"]
    end
    it "should give concat of nameParts if there is no displayForm subelement" do
      @mods.from_str('<mods><name><namePart>a</namePart><namePart>b</namePart></name></mods>')
      @mods.name.should == ["a b"]
    end
    it "should order the namePart elements according to their type attribute, if present" do
      pending "to be implemented"
    end
    it "should combine any and all subelements into a useful string" do
      pending "to be implemented"
      @mods.name.should == ["first name pieces", "second name pieces"]
    end
    
  end
  
  context "name subelements" do
    it "should get the text contents of any subelement" do
      Mods::Name::SUBELEMENTS.each { |elname|
        @mods.from_str("<mods><name><#{elname}>hi</#{elname}></name></mods>")
        @mods.name.send(elname.to_sym).should == ["hi"]
      }
    end
    
    it "should return an array of strings when there are multiple occurrences of subelements" do
      @mods.from_str('<mods><name><namePart>hi</namePart><namePart>hello</namePart></name</mods>')
      @mods.name.namePart.should == ["hi", "hello"]
    end
    
    it "should raise NoMethodError for incorrect subelements" do
      @mods.from_str("<mods><name><wrong>ignore</wrong></name></mods>")
      expect { @mods.name.wrong }.to raise_error(NoMethodError, /undefined method.*wrong/)
    end
    
    context "namePart subelement" do

      it "should recognize type attribute on namePart element" do
        Mods::Name::NAME_PART_TYPES.each { |t|  
          @mods.from_str("<mods><name><namePart type='#{t}'>hi</namePart></name></mods>")
          @mods.name.namePart.type.should == t
        }
      end

    end

    context "role subelement" do
      it "should work when there is no subelement" do
        pending "to be implemented"
      end
      it "should work when there is a roleTerm subelement" do
        pending "to be implemented"
      end
      it "should do something when there is some other illegal subelement" do
        pending "to be implemented"
      end
      it "should translate the marc relator code into text" do
        pending "to be implemented"
      end
    end
    
  end

  context "corporate names" do
    it "should include name elements with type attr = corporate" do
      pending "to be implemented"
    end
    it "should not include name elements with type attr != corporate" do
      pending "to be implemented"
    end
  end
  
end