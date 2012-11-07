module Mods

  class Name

    NS_HASH = {'m' => MODS_NS_V3}
    SUBELEMENTS = ['namePart', 'displayForm', 'affiliation', 'role', 'description']
        
    # attributes on name node
    ATTRIBUTES = ['type', 'authority', 'authorityURI', 'valueURI', 'displayLabel', 'usage', 'altRepGroup', 'nameTitleGroup']

    # valid values for type attribute on name node <name type="val"/>
    TYPES = ['personal', 'corporate', 'conference', 'family']
    # valid values for type attribute on namePart node <name><namePart type="val"/></name>
    NAME_PART_TYPES = ['date', 'family', 'given', 'termsOfAddress']
  
  end
  
end