# frozen_string_literal: true

module Mods
  class Subject
    CHILD_ELEMENTS = %w[topic geographic temporal titleInfo name genre hierarchicalGeographic
                        cartographics geographicCode occupation].freeze

    # attributes on subject node
    ATTRIBUTES = Mods::LANG_ATTRIBS + Mods::LINKING_ATTRIBS + ['authority']

    HIER_GEO_CHILD_ELEMENTS = %w[continent country province region state territory county city
                                 citySection island area extraterrestrialArea].freeze

    CARTOGRAPHICS_CHILD_ELEMENTS = %w[coordinates scale projection].freeze

    GEO_CODE_AUTHORITIES = ['marcgac, marccountry, iso3166'].freeze
  end
end
