# frozen_string_literal: true

require 'spec_helper'

describe 'Mods <originInfo> Element' do
  describe '#place' do
    describe '#place_term' do
      context 'with a single value' do
        let(:terms) do
          mods_record(<<-XML).origin_info.place.placeTerm
            <originInfo><place><placeTerm authority='marccountry' type='code'>fr</placeTerm></place></originInfo>
          XML
        end

        it 'has the expected attributes' do
          expect(terms.first).to have_attributes(
            authority: 'marccountry',
            type_at: 'code',
            text: 'fr'
          )
        end
      end

      context 'with a multi-valued place' do
        let(:terms) do
          mods_record(<<-XML).origin_info.place.placeTerm
            <originInfo>
              <place><placeTerm>France</placeTerm></place>
              <place><placeTerm>Italy</placeTerm></place>
            </originInfo>
          XML
        end

        it 'has elements for each place' do
          expect(terms.map(&:text)).to eq %w[France Italy]
        end
      end
    end
  end

  describe '#publisher' do
    subject(:publishers) do
      mods_record(<<-XML).origin_info.publisher
        <originInfo><publisher>Olney</publisher></origin_info>
      XML
    end

    it 'gets element values' do
      expect(publishers.map(&:text)).to eq(['Olney'])
    end
  end

  describe '#as_object' do
    describe '#key_dates' do
      it 'extracts the date with the keyDate attribute' do
        origin_info = mods_record("<originInfo><dateCreated>other date</dateCreated><dateCreated keyDate='yes'>key date</dateCreated></originInfo>").origin_info
        expect(origin_info.as_object.first.key_dates.first.text).to eq 'key date'
      end

      it 'extracts a date range when the keyDate attribute is on the start of the range' do
        origin_info = mods_record("<originInfo><dateCreated point='end'>other date</dateCreated><dateCreated keyDate='yes' point='start'>key date</dateCreated></originInfo>").origin_info
        expect(origin_info.as_object.first.key_dates.map(&:text)).to eq ['key date', 'other date']
      end
    end
  end

  Mods::ORIGIN_INFO_DATE_ELEMENTS.each do |elname|
    context "with <#{elname}> child elements" do
      it 'recognizes each element' do
        origin_info = mods_record("<originInfo><#{elname}>date</#{elname}></originInfo>").origin_info.send(elname.to_sym)
        expect(origin_info.map(&:text)).to eq(['date'])
      end

      it 'recognizes encoding attribute on each element' do
        origin_info = mods_record("<originInfo><#{elname} encoding='foo'>date</#{elname}></originInfo>").origin_info.send(elname.to_sym)
        expect(origin_info.encoding).to eq(['foo'])
      end

      it 'recognizes keyDate attribute' do
        origin_info = mods_record("<originInfo><#{elname} keyDate='foo'>date</#{elname}></originInfo>").origin_info.send(elname.to_sym)
        expect(origin_info.keyDate).to eq(['foo'])
      end

      it 'recognizes point attribute' do
        # NOTE: values allowed are 'start' and 'end'
        origin_info = mods_record("<originInfo><#{elname} point='foo'>date</#{elname}></originInfo>").origin_info.send(elname.to_sym)
        expect(origin_info.point).to eq(['foo'])
      end

      it 'recognizes qualifier attribute' do
        origin_info = mods_record("<originInfo><#{elname} qualifier='foo'>date</#{elname}></originInfo>").origin_info.send(elname.to_sym)
        expect(origin_info.qualifier).to eq(['foo'])
      end

      it 'recognizes type attribute only on dateOther' do
        origin_info = mods_record("<originInfo><#{elname} type='foo'>date</#{elname}></originInfo>").origin_info.send(elname.to_sym)
        if elname == 'dateOther'
          expect(origin_info.type_at).to eq(['foo'])
        else
          expect { origin_info.type_at }.to raise_exception(NoMethodError, /type_at/)
        end
      end
    end
  end

  context 'with edition' do
    subject(:origin_info) do
      mods_record(<<-XML).origin_info
        <originInfo><edition>7th ed.</edition></originInfo>
      XML
    end

    it 'gets element value' do
      expect(origin_info.edition).to have_attributes(text: '7th ed.')
    end
  end

  context 'with <issuance> child element' do
    subject(:origin_info) do
      mods_record(<<-XML).origin_info
        <originInfo><issuance>monographic</issuance></originInfo>
      XML
    end

    it 'gets element value' do
      expect(origin_info.issuance).to have_attributes(text: 'monographic')
    end
  end

  context 'with <frequency> child element' do
    subject(:origin_info) do
      mods_record(<<-XML).origin_info
        <originInfo><frequency authority='marcfrequency'>Annual</frequency></originInfo>
      XML
    end

    it 'has the right attributes' do
      expect(origin_info.frequency).to have_attributes(text: 'Annual', authority: ['marcfrequency'])
    end
  end
end
