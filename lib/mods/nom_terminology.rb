module Mods
  
  class Record
    
    # set the NOM terminology;  do NOT use namespaces
    # @param mods_ng_xml a Nokogiri::Xml::Document object containing MODS (without namespaces)
    def set_terminology_no_ns(mods_ng_xml)
      mods_ng_xml.set_terminology() do |t|

# FIXME: may want to deal with camelcase vs. underscore in method_missing 
 
        # These elements have no subelements - w00t!
        Mods::TOP_LEVEL_ELEMENTS_SIMPLE.each { |elname|
          t.send elname, :path => "/mods/#{elname}", :accessor => lambda { |e| e.text }
        }

        # TITLE_INFO ----------------------------------------------------------------------------
        # note - titleInfo can be a top level element or a sub-element of relatedItem 
        #   (<titleInfo> as subelement of <subject> is not part of the MODS namespace)
        
        t.title_info :path => '/mods/titleInfo' do |n|
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

        t.plain_name :path => '/mods/name' do |n|
          
          Mods::Name::ATTRIBUTES.each { |attr_name|
            n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
          
          n.namePart :path => 'namePart' do |np|
            np.type_at :path => '@type'
          end
          n.displayForm :path => 'displayForm'
          n.affiliation :path => 'affiliation'
          n.description :path => 'description'
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
          n.digitalOrigin :path => 'digitalOrigin', :accessor => lambda { |e| e.text }
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
          n.reformattingQuality :path => 'reformattingQuality', :accessor => lambda { |e| e.text }
        end
        
        # PHYSICAL_DESCRIPTION -------------------------------------------------------------------
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

