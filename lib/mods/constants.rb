module Mods
  # the version of MODS supported by this gem
  MODS_VERSION = '3.4'

  MODS_NS_V3 = "http://www.loc.gov/mods/v3"
  MODS_NS = MODS_NS_V3
  MODS_XSD = "http://www.loc.gov/standards/mods/mods.xsd"

  DOC_URL = "http://www.loc.gov/standards/mods/"

  # top level elements that cannot have subelement children
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

  # top level elements that can have subelement children
  TOP_LEVEL_ELEMENTS_COMPLEX = [
    'language',
    'location',
    'name',
    'originInfo',
    'part',
    'physicalDescription',
    'recordInfo',
    'relatedItem',
    'subject',
    'titleInfo' ]

  TOP_LEVEL_ELEMENTS = Array.new(TOP_LEVEL_ELEMENTS_SIMPLE).concat(TOP_LEVEL_ELEMENTS_COMPLEX)

  # enumerated attribute values
  TITLE_INFO_TYPES = ['abbreviated', 'translated', 'alternative', 'uniform']
  RELATED_ITEM_TYPES = [
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
