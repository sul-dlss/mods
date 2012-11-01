module Mods
  # the version of MODS supported by this gem
  MODS_VERSION = '3.4'
  
  MODS_NS_V3 = "http://www.loc.gov/mods/v3"
  MODS_NS = MODS_NS_V3
  MODS_XSD = "http://www.loc.gov/standards/mods/mods.xsd"

  DOC_URL = "http://www.loc.gov/standards/mods/"

  TOP_LEVEL_ELEMENTS_SIMPLE = [
    'abstract',
    'accessCondition',
    'classification',
    'extension',
    'genre',
    'identifier',
    'note',
    'tableOfContents',
    'targetAudience',
    'typeOfResource',
    ]

  TOP_LEVEL_ELEMENTS = [
    'abstract', 
    'accessCondition', 
    'classification',
    'extension', 
    'genre',
    'identifier',
    'language',
    'location',
    'name',
    'note', 
    'originInfo',
    'part',
    'physicalDescription',
    'recordInfo',
    'relatedItem',
    'subject',
    'tableOfContents',
    'targetAudience',
    'titleInfo',
    'typeOfResource' ]

  # enumerated attribute values
  TITLE_INFO_TYPE_ATTR_VALUES = ['abbreviated', 'translated', 'alternative', 'uniform']
  NAME_TYPE_ATTR_VALUES = ['personal', 'corporate', 'conference', 'family']
  RELATED_ITEM_TYPE_ATTR_VALUES = [
    'preceding', 'succeeding', 'original', 'host', 'constituent', 'series', 
    'otherVersion', 'otherFormat', 'isReferencedBy', 'references', 'reviewOf'
    ]

  # enumerated values
  TYPE_OF_RESOURCE_VALUES = [
    'text', 'cartographic', 'notated music', 'sound recording-musical', 'sound recording-nonmusical',
  'sound recording',
  'still image',
  'moving image',
  'three dimensional object',
  'software', 
  'multimedia',
  'mixed material']

end