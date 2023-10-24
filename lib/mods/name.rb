module Mods

  class Name

    CHILD_ELEMENTS = ['namePart', 'displayForm', 'affiliation', 'role', 'nameIdentifier', 'description']

    # attributes on name node
    ATTRIBUTES = Mods::AUTHORITY_ATTRIBS + Mods::LANG_ATTRIBS + ['type', 'displayLabel', 'usage', 'altRepGroup', 'nameTitleGroup']

    # valid values for type attribute on name node <name type="val"/>
    TYPES = ['personal', 'corporate', 'conference', 'family']
    # valid values for type attribute on namePart node <name><namePart type="val"/></name>
    NAME_PART_TYPES = ['date', 'family', 'given', 'termsOfAddress']

  end

end