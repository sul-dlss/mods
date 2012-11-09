module Mods

  class Subject

    CHILD_ELEMENTS = ['topic', 'geographic', 'temporal', 'titleInfo', 'name', 'genre', 'hierarchicalGeographic', 'cartographics', 'geographicCode', 'occupation']
        
    # attributes on subject node
    ATTRIBUTES = Mods::LANG_ATTRIBS + Mods::LINKING_ATTRIBS + ['authority']
    
    HIER_GEO_CHILD_ELEMENTS = ['continent', 'country', 'province', 'region', 'state', 'territory', 'county', 'city', 'citySection', 'island', 'area', 'extraterrestrialArea']
  
    CARTOGRAPHICS_CHILD_ELEMENTS = ['coordinates', 'scale', 'projection']
    
    GEO_CODE_AUTHORITIES = ['marcgac, marccountry, iso3166']
    
  end
  
end