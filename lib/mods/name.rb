# frozen_string_literal: true

module Mods
  class Name
    CHILD_ELEMENTS = %w[namePart displayForm affiliation role description].freeze

    # attributes on name node
    ATTRIBUTES = Mods::AUTHORITY_ATTRIBS + Mods::LANG_ATTRIBS + %w[type displayLabel usage altRepGroup
                                                                   nameTitleGroup]

    # valid values for type attribute on name node <name type="val"/>
    TYPES = %w[personal corporate conference family].freeze
    # valid values for type attribute on namePart node <name><namePart type="val"/></name>
    NAME_PART_TYPES = %w[date family given termsOfAddress].freeze
  end
end
