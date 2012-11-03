
module Mods

  # NAOMI_MUST_COMMENT_THIS_CLASS
  class Name

    attr_reader :ng_node
    
    NS_HASH = {'m' => MODS_NS_V3}
    SUBELEMENTS = ['namePart', 'displayForm', 'affiliation', 'role', 'description']
    
    
    # attributes on name node
    attr_accessor :type, :authority, :authorityURI, :valueURI, :displayLabel, :usage, :altRepGroup, :nameTitleGroup
    

    # NAOMI_MUST_COMMENT_THIS_METHOD
    def initialize(name_node)
      @ng_node = name_node
    end
    
    #  access child elements
    def method_missing method_name, *args
      method_name_as_str = method_name.to_s
      if SUBELEMENTS.include?(method_name_as_str)
# FIXME: this needs to cope with namespace aware, too
        @ng_node.xpath("#{method_name_as_str}").map { |node| node.text  }
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