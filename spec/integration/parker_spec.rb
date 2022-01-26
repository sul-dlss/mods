# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Parker manuscript' do
  let(:record) do
    Mods::Record.new.from_file(File.expand_path('../fixture_data/hp566jq8781.xml', __dir__))
  end

  it 'has title data' do
    expect(record.title_info).to match_array(
      [
        have_attributes(
          authority: 'Corpus Christi College',
          title: have_attributes(text: 'Cambridge, Corpus Christi College, MS 367: Miscellaneous Compilation including Old English Material and Historical and Philosophical Works')
        ),
        have_attributes(
          authority: 'James Catalog',
          type_at: 'alternative',
          title: have_attributes(text: 'Chronica. Anglo-Saxon fragments, etc.')
        )
      ]
    )

    expect(record.title_info.full_title).to match_array([
                                                          'Cambridge, Corpus Christi College, MS 367: Miscellaneous Compilation including Old English Material and Historical and Philosophical Works',
                                                          'Chronica. Anglo-Saxon fragments, etc.'
                                                        ])

    expect(record.title_info.short_title).to eq [
      'Cambridge, Corpus Christi College, MS 367: Miscellaneous Compilation including Old English Material and Historical and Philosophical Works'
    ]

    expect(record.title_info.sort_title).to eq [
      'Cambridge, Corpus Christi College, MS 367: Miscellaneous Compilation including Old English Material and Historical and Philosophical Works'
    ]

    expect(record.title_info.alternative_title).to eq [
      'Chronica. Anglo-Saxon fragments, etc.'
    ]
  end

  it 'has typeOfResource data' do
    expect(record.typeOfResource).to match_array([
                                                   have_attributes(
                                                     manuscript: 'yes',
                                                     text: 'mixed material'
                                                   )
                                                 ])
  end

  it 'has originInfo data' do
    expect(record.origin_info.to_a).to include(
      have_attributes(
        dateCreated: match_array([
                                   have_attributes(
                                     encoding: 'w3cdtf',
                                     keyDate: 'yes',
                                     point: 'start',
                                     qualifier: 'approximate',
                                     text: '1400'
                                   ),
                                   have_attributes(
                                     text: '1499'
                                   )
                                 ])
      ),
      have_attributes(
        dateCreated: match_array([
                                   have_attributes(
                                     text: '1300'
                                   ),
                                   have_attributes(
                                     text: '1399'
                                   )
                                 ])
      )
    )
  end

  it 'has abstract data' do
    expect(record.abstract).to match_array([
                                             have_attributes(
                                               displayLabel: 'Summary',
                                               type_at: 'summary',
                                               text: a_string_starting_with('CCCC MS 367')
                                             )
                                           ])
  end

  it 'has table of contents data' do
    expect(record.tableOfContents).to match_array([
                                                    have_attributes(
                                                      displayLabel: 'Contents',
                                                      text: a_string_starting_with('Polychronicon (epitome and continuation to 1429)')
                                                    )
                                                  ])
  end

  it 'has notes' do
    expect(record.note).to match_array([
                                         have_attributes(
                                           displayLabel: 'M.R. James Date',
                                           type_at: 'date',
                                           text: 'xv, xi-xii, xiv, xi'
                                         )
                                       ])
  end

  it 'has languages' do
    expect(record.language.length).to eq 2
    expect(record.language.code_term).to match_array([
                                                       have_attributes(
                                                         authority: 'iso639-2b',
                                                         text: 'lat',
                                                         type_at: 'code'
                                                       ),
                                                       have_attributes(
                                                         text: 'ang'
                                                       )
                                                     ])
    expect(record.language.text_term).to be_empty
  end

  it 'has a physical description' do
    expect(record.physical_description.first).to have_attributes(
      note: array_including(
        have_attributes(
          displayLabel: 'Material',
          type_at: 'material',
          text: 'Paper and vellum'
        ),
        have_attributes(
          text: 'five volumes'
        ),
        have_attributes(
          text: '220'
        )
      ),
      extent: match_array([
                            have_attributes(text: 'ff. 53 + 52')
                          ])
    )
  end

  it 'has identifiers' do
    expect(record.identifier.to_a).to include(
      have_attributes(
        text: '342',
        displayLabel: 'TJames'
      ),
      have_attributes(
        text: '19. 9',
        displayLabel: 'Stanley'
      )
    )
  end

  it 'has a location' do
    expect(record.location.to_a).to include(
      have_attributes(
        physicalLocation: have_attributes(
          text: 'UK, Cambridge, Corpus Christi College, Parker Library',
          type_at: ['repository']
        ),
        shelfLocator: have_attributes(
          text: 'MS 367'
        )
      )
    )
  end

  it 'has related items' do
    expect(record.related_item.to_a).to include(
      have_attributes(
        displayLabel: 'Downloadable James Catalogue Record',
        type_at: 'isReferencedBy',
        titleInfo: array_including(
          have_attributes(
            title: have_attributes(
              text: a_string_starting_with('https://stacks.stanford.edu')
            )
          )
        )
      ),
      have_attributes(
        type_at: 'constituent',
        titleInfo: array_including([
                                     have_attributes(
                                       title: [
                                         have_attributes(text: 'Ranulf Higden OSB, Polychronicon (epitome and continuation to 1429)')
                                       ],
                                       partNumber: [
                                         have_attributes(text: '1r-29v')
                                       ]
                                     )
                                   ]),
        note: array_including(
          have_attributes(text: 'Dates are marked in the margin'),
          have_attributes(type_at: 'incipit', text: a_string_starting_with('(1r) Ieronimus'))
        )
      )
    )
  end

  it 'has access conditions' do
    expect(record.accessCondition).to match_array([
                                                    have_attributes(
                                                      type_at: 'useAndReproduction',
                                                      text: a_string_starting_with('Images courtesy')
                                                    ),
                                                    have_attributes(
                                                      type_at: 'license',
                                                      text: a_string_starting_with('CC by-nc: Attribution')
                                                    )
                                                  ])
  end
end
