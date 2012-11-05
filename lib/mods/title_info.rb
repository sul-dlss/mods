module Mods
  # NAOMI_MUST_COMMENT_THIS_CLASS
  class TitleInfo
    attr_reader :ng_node
    
    NS_HASH = {'m' => MODS_NS_V3}
    SUBELEMENTS = ['title', 'subTitle', 'partNumber', 'partName', 'nonSort']
        
    # attributes on titleInfo node
    ATTRIBUTES = ['type', 'authority', 'authorityURI', 'valueURI', 'displayLabel', 'supplied', 'usage', 'altRepGroup', 'nameTitleGroup']

    # valid values for type attribute on titleInfo node <titleInfo type="val">
    TYPES = ['abbreviated', 'translated', 'alternative', 'uniform']
    
    # @param (Nokogiri::XML::Node) mods:titleInfo node
    def initialize(title_info_node)
      @ng_node = title_info_node
    end
    
  end
  
end