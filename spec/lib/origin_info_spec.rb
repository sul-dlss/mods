# encoding: utf-8
require 'spec_helper'

describe "Mods <originInfo> Element" do
  context "<place> child element" do
    let(:place_term_plain_mult) do
      mods_record(<<-XML).origin_info.place.placeTerm
        <originInfo>
          <place><placeTerm>France</placeTerm></place>
          <place><placeTerm>Italy</placeTerm></place>
        </originInfo>
      XML
    end

    let(:place_term_code) do
      mods_record(<<-XML).origin_info.place.placeTerm
        <originInfo><place><placeTerm authority='marccountry' type='code'>fr</placeTerm></place></originInfo>
      XML
    end

    context "<placeTerm> child element" do
      it "should get element values" do
        expect(place_term_plain_mult.map(&:text)).to eq ['France', 'Italy']
      end
      it "should get authority attribute" do
        expect(place_term_code.authority).to eq(["marccountry"])
      end
      it "should get type(_at) attribute" do
        expect(place_term_code.type_at).to eq(["code"])
      end
    end # placeTerm
  end # place

  context "<publisher> child element" do
    subject(:origin_info) do
      mods_record(<<-XML).origin_info
        <originInfo><publisher>Olney</publisher></origin_info>
      XML
    end

    it "should get element values" do
      expect(origin_info.publisher.map(&:text)).to eq(["Olney"])
    end
  end

  describe '#as_object' do
    describe '#key_dates' do
      it 'should extract the date with the keyDate attribute' do
        origin_info = mods_record("<originInfo><dateCreated>other date</dateCreated><dateCreated keyDate='yes'>key date</dateCreated></originInfo>").origin_info
        expect(origin_info.as_object.first.key_dates.first.text).to eq 'key date'
      end
      it 'should extract a date range when the keyDate attribute is on the start of the range' do
        origin_info = mods_record("<originInfo><dateCreated point='end'>other date</dateCreated><dateCreated keyDate='yes' point='start'>key date</dateCreated></originInfo>").origin_info
        expect(origin_info.as_object.first.key_dates.map(&:text)).to eq ['key date', 'other date']
      end
    end
  end

  Mods::ORIGIN_INFO_DATE_ELEMENTS.each do |elname|
    context "<#{elname}> child elements" do
      it "should recognize each element" do
        origin_info = mods_record("<originInfo><#{elname}>date</#{elname}></originInfo>").origin_info.send(elname.to_sym)
        expect(origin_info.map(&:text)).to eq(["date"])
      end
      it "should recognize encoding attribute on each element" do
        origin_info = mods_record("<originInfo><#{elname} encoding='foo'>date</#{elname}></originInfo>").origin_info.send(elname.to_sym)
        expect(origin_info.encoding).to eq(["foo"])
      end
      it "should recognize keyDate attribute" do
        origin_info = mods_record("<originInfo><#{elname} keyDate='foo'>date</#{elname}></originInfo>").origin_info.send(elname.to_sym)
        expect(origin_info.keyDate).to eq(["foo"])
      end
      it "should recognize point attribute" do
      # NOTE: values allowed are 'start' and 'end'
        origin_info = mods_record("<originInfo><#{elname} point='foo'>date</#{elname}></originInfo>").origin_info.send(elname.to_sym)
        expect(origin_info.point).to eq(["foo"])
      end
      it "should recognize qualifier attribute" do
        origin_info = mods_record("<originInfo><#{elname} qualifier='foo'>date</#{elname}></originInfo>").origin_info.send(elname.to_sym)
        expect(origin_info.qualifier).to eq(["foo"])
      end
      it "should recognize type attribute only on dateOther" do
        origin_info = mods_record("<originInfo><#{elname} type='foo'>date</#{elname}></originInfo>").origin_info.send(elname.to_sym)
        if elname == 'dateOther'
          expect(origin_info.type_at).to eq(["foo"])
        else
          expect { origin_info.type_at}.to raise_exception(NoMethodError, /type_at/)
        end
      end
    end # <xxxDate> child elements
  end

  context 'edition' do
    subject(:origin_info) do
      mods_record(<<-XML).origin_info
        <originInfo><edition>7th ed.</edition></originInfo>
      XML
    end

    it "gets element value" do
      expect(origin_info.edition).to have_attributes(text: '7th ed.')
    end
  end

  context "<issuance> child element" do
    subject(:origin_info) do
      mods_record(<<-XML).origin_info
        <originInfo><issuance>monographic</issuance></originInfo>
      XML
    end

    it "gets element value" do
      expect(origin_info.issuance).to have_attributes(text: 'monographic')
    end
  end

  context "<frequency> child element" do
    subject(:origin_info) do
      mods_record(<<-XML).origin_info
        <originInfo><frequency authority='marcfrequency'>Annual</frequency></originInfo>
      XML
    end

    it "has the right attributes" do
      expect(origin_info.frequency).to have_attributes(text: 'Annual', authority: ['marcfrequency'])
    end
  end
end
