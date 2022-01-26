# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Mods <recordInfo> Element' do
  context 'with some basic record info' do
    subject(:record_info) do
      mods_record("<recordInfo>
              <recordContentSource authority='marcorg'>RQE</recordContentSource>
              <recordCreationDate encoding='marc'>890517</recordCreationDate>
              <recordIdentifier source='SIRSI'>a9079953</recordIdentifier>
            </recordInfo>").record_info
    end

    it 'has the expected attributes' do
      expect(record_info.first).to have_attributes(
        recordContentSource: match_array(have_attributes(
                                           authority: 'marcorg',
                                           text: 'RQE'
                                         )),
        recordCreationDate: match_array(have_attributes(
                                          encoding: 'marc',
                                          text: '890517'
                                        )),
        recordIdentifier: match_array(have_attributes(
                                        source: 'SIRSI',
                                        text: 'a9079953'
                                      ))
      )
    end
  end

  context 'with some more expansive record info' do
    subject(:record_info) do
      mods_record("<recordInfo>
                <descriptionStandard>aacr2</descriptionStandard>
                <recordContentSource authority='marcorg'>AU@</recordContentSource>
                <recordCreationDate encoding='marc'>050921</recordCreationDate>
                <recordIdentifier source='SIRSI'>a8837534</recordIdentifier>
                <languageOfCataloging>
                  <languageTerm authority='iso639-2b' type='code'>eng</languageTerm>
                </languageOfCataloging>
            </recordInfo>").record_info
    end

    it 'has the expected attributes' do
      expect(record_info.first).to have_attributes(
        descriptionStandard: match_array(have_attributes(text: 'aacr2')),
        recordContentSource: match_array(have_attributes(
                                           authority: 'marcorg',
                                           text: 'AU@'
                                         )),
        recordCreationDate: match_array(have_attributes(
                                          encoding: 'marc',
                                          text: '050921'
                                        )),
        recordIdentifier: match_array(have_attributes(
                                        source: 'SIRSI',
                                        text: 'a8837534'
                                      )),
        languageOfCataloging: match_array(have_attributes(
                                            languageTerm: match_array(have_attributes(
                                                                        authority: 'iso639-2b',
                                                                        type_at: 'code',
                                                                        text: 'eng'
                                                                      ))
                                          ))
      )
    end
  end

  context 'with an rlin record info' do
    subject(:record_info) do
      mods_record("<recordInfo>
                <descriptionStandard>appm</descriptionStandard>
                <recordContentSource authority='marcorg'>CSt</recordContentSource>
                <recordCreationDate encoding='marc'>850416</recordCreationDate>
                <recordChangeDate encoding='iso8601'>19991012150824.0</recordChangeDate>
                <recordIdentifier source='CStRLIN'>a4083219</recordIdentifier>
            </recordInfo>").record_info
    end

    it 'has the expected attributes' do
      expect(record_info.first).to have_attributes(
        recordChangeDate: match_array(have_attributes(
                                        encoding: 'iso8601',
                                        text: '19991012150824.0'
                                      ))
      )
    end
  end

  context 'with a displayLabel' do
    subject(:record) do
      mods_record("<recordInfo displayLabel='val'><recordOrigin>nowhere</recordOrigin></recordInfo></mods>")
    end

    it 'has the expected attributes' do
      expect(record.record_info.first).to have_attributes(
        displayLabel: 'val'
      )
    end
  end

  context 'with a recordOrigin' do
    subject(:record) do
      mods_record('<recordInfo><recordOrigin>human prepared</recordOrigin></recordInfo></mods>')
    end

    it 'has the expected attributes' do
      expect(record.record_info.first).to have_attributes(
        recordOrigin: have_attributes(text: 'human prepared')
      )
    end
  end
end
