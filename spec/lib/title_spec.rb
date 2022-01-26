# frozen_string_literal: true

require 'spec_helper'

describe 'Mods <titleInfo> element' do
  it 'recognizes type attribute on titleInfo element' do
    Mods::TitleInfo::TYPES.each do |t|
      record = mods_record("<titleInfo type='#{t}'>hi</titleInfo>")
      expect(record.title_info.type_at).to eq([t])
    end
  end

  it 'recognizes subelements' do
    Mods::TitleInfo::CHILD_ELEMENTS.each do |e|
      record = mods_record("<titleInfo><#{e}>oofda</#{e}></titleInfo>")
      expect(record.title_info.send(e).text).to eq('oofda')
    end
  end

  context 'with short_title' do
    it 'starts with nonSort element' do
      record = mods_record('<titleInfo><title>Jerk</title><nonSort>The</nonSort></titleInfo>')
      expect(record.title_info.short_title).to eq(['The Jerk'])
    end

    it 'does not include subtitle' do
      record = mods_record('<titleInfo><title>Jerk</title><subTitle>A Tale of Tourettes</subTitle><nonSort>The</nonSort></titleInfo>')
      expect(record.title_info.short_title).to eq(['The Jerk'])
    end

    it 'Mods::Record.short_titles convenience method should return an Array (multiple titles are legal in Mods)' do
      record = mods_record('<titleInfo><title>Jerk</title><nonSort>The</nonSort></titleInfo><titleInfo><title>Joke</title></titleInfo>')
      expect(record.short_titles).to eq(['The Jerk', 'Joke'])
    end

    it 'does not include alternative titles' do
      record = mods_record("<titleInfo type='alternative'><title>ta da!</title></titleInfo>")
      expect(record.short_titles).not_to include('ta da!')
      record = mods_record("<titleInfo type='alternative'><title>1</title></titleInfo><titleInfo><title>2</title></titleInfo>")
      expect(record.short_titles).to eq(['2'])
    end
    # NOTE: that Mods::Record.short_title tests are in record_spec
  end

  context 'with full_title' do
    it 'starts with nonSort element' do
      record = mods_record('<titleInfo><title>Jerk</title><nonSort>The</nonSort></titleInfo>')
      expect(record.title_info.full_title).to eq(['The Jerk'])
    end

    it 'includes subtitle' do
      record = mods_record('<titleInfo><title>Jerk</title><subTitle>A Tale of Tourettes</subTitle><nonSort>The</nonSort></titleInfo>')
      expect(record.title_info.full_title).to eq(['The Jerk A Tale of Tourettes'])
    end

    it 'Mods::Record.full_titles convenience method should return an Array (multiple titles are legal in Mods)' do
      record = mods_record('<titleInfo><title>Jerk</title><nonSort>The</nonSort></titleInfo><titleInfo><title>Joke</title></titleInfo>')
      expect(record.full_titles).to eq(['The Jerk', 'Joke'])
    end
    # NOTE: that Mods::Record.full_title tests are in record_spec
  end

  context 'with sort_title' do
    it 'skips nonSort element' do
      record = mods_record('<titleInfo><title>Jerk</title><nonSort>The</nonSort></titleInfo>')
      expect(record.title_info.sort_title).to eq(['Jerk'])
    end

    it 'contains title and subtitle' do
      record = mods_record('<titleInfo><title>Jerk</title><subTitle>A Tale of Tourettes</subTitle><nonSort>The</nonSort></titleInfo>')
      expect(record.title_info.sort_title).to eq(['Jerk A Tale of Tourettes'])
    end

    it 'is an alternative title if there are no other choices' do
      record = mods_record("<titleInfo type='alternative'><title>1</title></titleInfo>")
      expect(record.title_info.sort_title).to eq(['1'])
    end

    it 'is not an alternative title if there are other choices' do
      record = mods_record("<titleInfo type='alternative'><title>1</title></titleInfo><titleInfo><title>2</title></titleInfo>")
      expect(record.title_info.sort_title).to eq(['2'])
      expect(record.sort_title).to eq('2')
    end

    it 'has a configurable delimiter between title and subtitle' do
      m = Mods::Record.new(' : ')
      m.from_str("<mods xmlns='#{Mods::MODS_NS}'><titleInfo><title>Jerk</title><subTitle>A Tale of Tourettes</subTitle><nonSort>The</nonSort></titleInfo></mods>")
      expect(m.title_info.sort_title).to eq(['Jerk : A Tale of Tourettes'])
    end

    context 'with Mods::Record.sort_title convenience method' do
      it 'convenience method sort_title in Mods::Record should return a string' do
        record = mods_record('<titleInfo><title>Jerk</title><subTitle>A Tale of Tourettes</subTitle><nonSort>The</nonSort></titleInfo>')
        expect(record.sort_title).to eq('Jerk A Tale of Tourettes')
      end
    end
    # NOTE: that Mods::Record.sort_title tests are in record_spec
  end

  context 'with alternative_title' do
    it 'gets an alternative title, if it exists' do
      record = mods_record("<titleInfo type='alternative'><title>ta da!</title></titleInfo>")
      expect(record.title_info.alternative_title).to eq(['ta da!'])
    end

    it 'Mods::Record.alternative_titles convenience method for getting an Array of alternative titles when there are multiple elements' do
      record = mods_record("<titleInfo type='alternative'><title>1</title></titleInfo><titleInfo type='alternative'><title>2</title></titleInfo>")
      expect(record.alternative_titles).to eq(%w[1 2])
      record = mods_record("<titleInfo type='alternative'><title>1</title><title>2</title></titleInfo>")
      expect(record.alternative_titles).to eq(['12'])
    end

    it 'does not get an alternative title if type attribute is absent from titleInfo' do
      record = mods_record('<titleInfo><title>ta da!</title></titleInfo>')
      expect(record.alternative_titles).to eq([])
    end

    it "does not get an alternative title if type attribute from titleInfo is not 'alternative'" do
      record = mods_record("<titleInfo type='uniform'><title>ta da!</title></titleInfo>")
      expect(record.alternative_titles).to eq([])
    end
    # NOTE: that Mods::Record.alternative_title tests are in record_spec
  end
end
