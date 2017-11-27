require 'nokogiri'
require 'nom/xml'

module Mods
  require 'mods/constants'
  require 'mods/nom_terminology'
  require 'mods/date'
  require 'mods/marc_country_codes'
  require 'mods/marc_geo_area_codes'
  require 'mods/marc_relator_codes'
  require 'mods/name'
  require 'mods/origin_info'
  require 'mods/reader'
  require 'mods/record'
  require 'mods/subject'
  require 'mods/title_info'
  require 'mods/version'

  ORIGIN_INFO_DATE_ELEMENTS = Mods::OriginInfo::DATE_ELEMENTS
end
