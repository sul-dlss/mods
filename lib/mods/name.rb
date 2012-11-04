
module Mods

  # NAOMI_MUST_COMMENT_THIS_CLASS
  class Name

    attr_reader :ng_node
    
    NS_HASH = {'m' => MODS_NS_V3}
    SUBELEMENTS = ['namePart', 'displayForm', 'affiliation', 'role', 'description']
        
    # attributes on name node
    ATTRIBUTES = ['type', 'authority', 'authorityURI', 'valueURI', 'displayLabel', 'usage', 'altRepGroup', 'nameTitleGroup']

    # valid values for type attribute on name node <name type="val"/>
    NAME_TYPES = ['personal', 'corporate', 'conference', 'family']
    # valid values for type attribute on namePart node <name><namePart type="val"/></name>
    NAME_PART_TYPES = ['date', 'family', 'given', 'termsOfAddress']

    # @param (Nokogiri::XML::Node) the mods:name node, as a Nokogiri::XML::Node object
    def initialize(name_node)
      @ng_node = name_node
    end
    
    # calls Nokogiri::Node.text on the mods:name node
    def text
      @ng_node.text.to_s
    end
    
    #  access child elements
    def method_missing method_name, *args
      method_name_as_str = method_name.to_s
      if SUBELEMENTS.include?(method_name_as_str)
# FIXME: this needs to cope with namespace aware, too
        @ng_node.xpath("#{method_name_as_str}").map { |node| node.text.to_s  }
      elsif ATTRIBUTES.include?(method_name_as_str) 
        # attributes (which are unrepeatable) on name node 
        @ng_node.at_xpath("@#{method_name_as_str}").text.to_s
      else 
        super.method_missing(method_name, *args)
      end
    end    
        
  end
  
  # NAOMI_MUST_COMMENT_THIS_CLASS
  class RoleTerm
    # attributes of roleTerm element
    attr_accessor :type, :authority, :authorityURI, :valueURI
    
  end
  
  
  
end