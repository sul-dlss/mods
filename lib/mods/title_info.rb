module Mods

  class TitleInfo
    
    CHILD_ELEMENTS = ['title', 'subTitle', 'partNumber', 'partName', 'nonSort']
        
    # attributes on titleInfo node
    ATTRIBUTES = Mods::AUTHORITY_ATTRIBS + ['type', 'displayLabel', 'supplied', 'usage', 'altRepGroup', 'nameTitleGroup']

    # valid values for type attribute on titleInfo node <titleInfo type="val">
    TYPES = ['abbreviated', 'translated', 'alternative', 'uniform']
    
    DEFAULT_TITLE_DELIM = ' '
    
#    attr_reader :ng_node

    # @param (Nokogiri::XML::Node) mods:titleInfo node
#    def initialize(title_info_node)
#      @ng_node = title_info_node
#    end
    
  end
  
end