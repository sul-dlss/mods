# frozen_string_literal: true

module Mods
  class TitleInfo
    CHILD_ELEMENTS = %w[title subTitle partNumber partName nonSort].freeze

    # attributes on titleInfo node
    ATTRIBUTES = Mods::AUTHORITY_ATTRIBS + Mods::LANG_ATTRIBS + %w[type displayLabel supplied usage
                                                                   altRepGroup nameTitleGroup]

    # valid values for type attribute on titleInfo node <titleInfo type="val">
    TYPES = %w[abbreviated translated alternative uniform].freeze

    DEFAULT_TITLE_DELIM = ' '

    #    attr_reader :ng_node

    # @param (Nokogiri::XML::Node) mods:titleInfo node
    #    def initialize(title_info_node)
    #      @ng_node = title_info_node
    #    end
  end
end
