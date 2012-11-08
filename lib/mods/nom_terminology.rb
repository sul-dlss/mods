module Mods
  
  # from:  http://www.loc.gov/standards/mods/v3/mods-userguide-generalapp.html
  
  LANG_ATTRIBS = ['lang', 'xml:lang', 'script', 'transliteration']
  
  LINKING_ATTRIBS = ['xlink', 'ID']

  DATE_ATTRIBS = ['encoding', 'point', 'keyDate', 'qualifier']
  ENCODING_ATTRIB_VALUES = ['w3cdtf', 'iso8601', 'marc']
  POINT_ATTRIB_VALUES = ['start', 'end']
  KEY_DATE_ATTRIB_VALUEs = ['yes']
  QUALIFIER_ATTRIB_VALUES = ['approximate', 'inferred', 'questionable']
  
  AUTHORITY_ATTRIBS = ['authority', 'authorityURI', 'valueURI']

  class Record
    
    # set the NOM terminology;  do NOT use namespaces
    # @param mods_ng_xml a Nokogiri::Xml::Document object containing MODS (without namespaces)
    def set_terminology_no_ns(mods_ng_xml)
      mods_ng_xml.set_terminology() do |t|

# FIXME: may want to deal with camelcase vs. underscore in method_missing 
 
        # These elements have no subelements - w00t!
        Mods::TOP_LEVEL_ELEMENTS_SIMPLE.each { |elname|
          t.send elname, :path => "/mods/#{elname}"
        }

        # TITLE_INFO ----------------------------------------------------------------------------
        # note - titleInfo can be a top level element or a sub-element of relatedItem 
        #   (<titleInfo> as subelement of <subject> is not part of the MODS namespace)
        
        t.title_info :path => '/mods/titleInfo'
        
        t._title_info :path => '//titleInfo' do |n|
          n.type_at :path => '@type'
          n.title :path => 'title'
          n.subTitle :path => 'subTitle'
          n.nonSort :path => 'nonSort'
          n.partNumber :path => 'partNumber'
          n.partName :path => 'partName'
          n.sort_title :path => '.', :accessor => lambda { |node| 
            if node.type_at.text != "alternative" || (node.type_at.text == "alternative" && mods_ng_xml.xpath('/mods/titleInfo').size == 1)
              node.title.text + (!node.subTitle.text.empty? ? "#{@title_delimiter}#{node.subTitle.text}" : "" ) 
            end
          }
          n.full_title :path => '.', :accessor => lambda { |node| 
             (!node.nonSort.text.empty? ? "#{node.nonSort.text} " : "" ) + 
             node.title.text + 
             (!node.subTitle.text.empty? ? "#{@title_delimiter}#{node.subTitle.text}" : "" ) 
          }
          n.short_title :path => '.', :accessor => lambda { |node|  
            if node.type_at.text != "alternative"
              (!node.nonSort.text.empty? ? "#{node.nonSort.text} " : "" ) + 
              node.title.text
            end
          }
          n.alternative_title :path => '.', :accessor => lambda { |node|  
            if node.type_at.text == "alternative"
              (!node.nonSort.text.empty? ? "#{node.nonSort.text} " : "" ) + 
              node.title.text
            end
          }
        end
        
        # current way to do short_title correctly
#        t.short_title :path => '/mods/titleInfo[not(@type=alternative)]', :accessor => lambda { |node|  
#            (!node.nonSort.text.empty? ? "#{node.nonSort.text} " : "" ) + 
#            node.title.text
#          }


        # NAME ------------------------------------------------------------------------------------
        t.plain_name :path => '/mods/name'

        t._plain_name :path => '//name' do |n|
          
          Mods::Name::ATTRIBUTES.each { |attr_name|
            if attr_name != 'type'
              n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            else
              n.type_at :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            end
          }
          
          n.namePart :path => 'namePart' do |np|
            np.type_at :path => '@type'
          end
          n.displayForm :path => 'displayForm'
          n.affiliation :path => 'affiliation'
          n.description_el :path => 'description' # description is used by Nokogiri
          n.role :path => 'role/roleTerm' do |r|
            r.type_at :path => "@type", :accessor => lambda { |a| a.text }
            r.authority :path => "@authority", :accessor => lambda { |a| a.text }
          end
        end

        t.personal_name :path => '/mods/name[@type="personal"]' do |n|
          n.family_name :path => 'namePart[@type="family"]'
          n.given_name :path => 'namePart[@type="given"]'
          n.termsOfAddress :path => 'namePart[@type="termsOfAddress"]'
          n.date :path => 'namePart[@type="date"]'
        end
        
        t.corporate_name :path => '/mods/name[@type="corporate"]'
        t.conference_name :path => '/mods/name[@type="conference"]'

        # LANGUAGE -------------------------------------------------------------------------------

        t.language :path => '/mods/language' do |n|
          n.languageTerm :path => 'languageTerm' do |lt|
            lt.type_at :path => '@type', :accessor => lambda { |a| a.text }
            lt.authority :path => '@authority', :accessor => lambda { |a| a.text }
          end
          n.code_term :path => 'languageTerm[@type="code"]'
          n.text_term :path => 'languageTerm[@type="text"]'
          n.scriptTerm :path => 'scriptTerm'
        end

        # PHYSICAL_DESCRIPTION -------------------------------------------------------------------
        t.physical_description :path => '/mods/physicalDescription' do |n|
          n.digitalOrigin :path => 'digitalOrigin'
          n.extent :path => 'extent'
          n.form :path => 'form' do |f|
            f.authority :path => '@authority', :accessor => lambda { |a| a.text }
            f.type_at :path => '@type', :accessor => lambda { |a| a.text }
          end
          n.internetMediaType :path => 'internetMediaType'
          n.note :path => 'note' do |nn|
            nn.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
            nn.type_at :path => '@type', :accessor => lambda { |a| a.text }
          end
          n.reformattingQuality :path => 'reformattingQuality'
        end
        
        # LOCATION -------------------------------------------------------------------------------
        t.location :path => '/mods/location' do |n|
          n.physicalLocation :path => 'physicalLocation' do |e|
            e.authority :path => '@authority', :accessor => lambda { |a| a.text }
            e.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
          end
          n.shelfLocator :path => 'shelfLocator'
          n.url :path => 'url' do |e|
            e.dateLastAccessed :path => '@dateLastAccessed', :accessor => lambda { |a| a.text }
            e.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
            e.note :path => '@note', :accessor => lambda { |a| a.text }
            e.access :path => '@access', :accessor => lambda { |a| a.text }
            e.usage :path => '@usage', :accessor => lambda { |a| a.text }
          end
          n.holdingSimple :path => 'holdingSimple'
          n.holdingExternal :path => 'holdingExternal'
        end
        
        # ORIGIN_INFO --------------------------------------------------------------------------
        t.origin_info :path => '/mods/originInfo' do |n|
          n.place :path => 'place' do |e|
            e.placeTerm :path => 'placeTerm' do |ee|
              ee.type_at :path => '@type', :accessor => lambda { |a| a.text }
              ee.authority :path => '@authority', :accessor => lambda { |a| a.text }
            end
          end
          n.publisher :path => 'publisher'
          Mods::ORIGIN_INFO_DATE_ELEMENTS.each { |date_el|
            n.send date_el, :path => "#{date_el}" do |d|
              d.encoding :path => '@encoding', :accessor => lambda { |a| a.text }
              d.point :path => '@point', :accessor => lambda { |a| a.text }
              d.keyDate :path => '@keyDate', :accessor => lambda { |a| a.text }
              d.qualifier :path => '@qualifier', :accessor => lambda { |a| a.text }
              if date_el == 'dateOther'
                d.type_at :path => '@type', :accessor => lambda { |a| a.text }
              end
            end
          }
          n.edition :path => 'edition'
          n.issuance :path => 'issuance'
          n.frequency :path => 'frequency' do |f|
            f.authority :path => '@authority', :accessor => lambda { |a| a.text }
          end
        end
        
      end # terminology

      mods_ng_xml.nom!

      mods_ng_xml
    end # set_terminology_no_ns

# TODO: common top level element attributes:  ID; xlink; lang; xml:lang; script; transliteration 
#       authority, authorityURI, valueURI
#       displayLabel, usage altRepGroup
#       type
# TODO:   common subelement attributes:   lang, xml:lang, script, transliteration
# TODO: other common attribute:  supplied
    
    
    # set the NOM terminology, with namespaces
    # @param mods_ng_xml a Nokogiri::Xml::Document object containing MODS (with namespaces)
    def set_terminology_ns(mods_ng_xml)
      mods_ng_xml.set_terminology(:namespaces => { 'm' => Mods::MODS_NS}) do |t|

        # note - titleInfo can be a top level element or a sub-element of subject and relatedItem
        t.title_info :path => '//m:titleInfo' do |n|
          n.title :path => 'm:title'
          n.subTitle :path => 'm:subTitle'
          n.nonSort :path => 'm:nonSort'
          n.partNumber :path => 'm:partNumber'
          n.partName :path => 'm:partName'
          n.type_at :path => '@type'
        end

        t.author :path => '//m:name' do |n|
          n.valueURI :path => '@valueURI'
          n.namePart :path => 'm:namePart', :single => true
        end

        t.corporate_authors :path => '//m:name[@type="corporate"]'
        t.personal_authors :path => 'm:name[@type="personal"]' do |n|
          n.roleTerm :path => 'm:role/m:roleTerm'
          n.name_role_pair :path => '.', :accessor => lambda { |node| node.roleTerm.text + ": " + node.namePart.text }
        end

        t.language :path => 'm:language' do |n|
          n.value :path => 'm:languageTerm', :accessor => :text
        end

      end
      
      mods_ng_xml.nom!
      
      mods_ng_xml
    end # set_terminology_ns
    
  end
  
end

