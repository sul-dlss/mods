module Mods
  
  # from:  http://www.loc.gov/standards/mods/v3/mods-userguide-generalapp.html
  
  LANG_ATTRIBS = ['lang', 'xml:lang', 'script', 'transliteration']
  
  LINKING_ATTRIBS = ['xlink', 'ID']

  DATE_ATTRIBS = ['encoding', 'point', 'keyDate', 'qualifier']
  ENCODING_ATTRIB_VALUES = ['w3cdtf', 'iso8601', 'marc', 'edtf', 'temper']
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
        
        # ABSTRACT -------------------------------------------------------------------------------
        t._abstract :path => '//abstract' do |n|
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
          n.type_at :path => '@type', :accessor => lambda { |a| a.text }
        end
        
        # ACCESS_CONDITION -----------------------------------------------------------------------
        t._accessCondition :path => '//accessCondition' do |n|
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
          n.type_at :path => '@type', :accessor => lambda { |a| a.text }
        end
        
        # CLASSIFICATION -------------------------------------------------------------------------
        t._classification :path => '//classification' do |n|
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
          n.edition :path => '@edition', :accessor => lambda { |a| a.text }
          Mods::AUTHORITY_ATTRIBS.each { |attr_name|
            n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
        end        
        
        # EXTENSION ------------------------------------------------------------------------------
        t._extension :path => '//extension' do |n|
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
        end
        
        # GENRE ----------------------------------------------------------------------------------
        t._genre :path => '//genre' do |n|
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
          n.type_at :path => '@type', :accessor => lambda { |a| a.text }
          n.usage :path => '@usage', :accessor => lambda { |a| a.text }
          Mods::AUTHORITY_ATTRIBS.each { |attr_name|
            n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
        end
        
        # IDENTIIER ------------------------------------------------------------------------------
        t._identifier :path => '//identifier' do |n|
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
          n.invalid :path => '@invalid', :accessor => lambda { |a| a.text }
          n.type_at :path => '@type', :accessor => lambda { |a| a.text }
        end
        
        # LANGUAGE -------------------------------------------------------------------------------
        t.language :path => '/mods/language'
        t._language :path => '//language' do |n|
          n.languageTerm :path => 'languageTerm'
          n.code_term :path => 'languageTerm[@type="code"]'
          n.text_term :path => 'languageTerm[@type="text"]'
          n.scriptTerm :path => 'scriptTerm'
        end
        t._languageTerm :path => '//languageTerm' do |lt|
          lt.type_at :path => '@type', :accessor => lambda { |a| a.text }
          Mods::AUTHORITY_ATTRIBS.each { |attr_name|
            lt.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
        end # t.language

        # LOCATION -------------------------------------------------------------------------------
        t.location :path => '/mods/location'
        t._location :path => '//location' do |n|
          n.physicalLocation :path => 'physicalLocation' do |e|
            e.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
            Mods::AUTHORITY_ATTRIBS.each { |attr_name|
              e.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
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
        end # t.location
        
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
          # elements
          n.namePart :path => 'namePart' do |np|
            np.type_at :path => '@type', :accessor => lambda { |a| a.text }
          end
          n.displayForm :path => 'displayForm'
          n.affiliation :path => 'affiliation'
          n.description_el :path => 'description' # description is used by Nokogiri
          n.role :path => 'role/roleTerm' do |r|
            r.type_at :path => "@type", :accessor => lambda { |a| a.text }
            Mods::AUTHORITY_ATTRIBS.each { |attr_name|
              r.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
          end
        end # t._plain_name

        t.personal_name :path => '/mods/name[@type="personal"]'
        t._personal_name :path => '//name[@type="personal"]' do |n|
          n.family_name :path => 'namePart[@type="family"]'
          n.given_name :path => 'namePart[@type="given"]'
          n.termsOfAddress :path => 'namePart[@type="termsOfAddress"]'
          n.date :path => 'namePart[@type="date"]'
        end
        
        t.corporate_name :path => '/mods/name[@type="corporate"]'
        t._corporate_name :path => '//name[@type="corporate"]'
        t.conference_name :path => '/mods/name[@type="conference"]'
        t._conference_name :path => '//name[@type="conference"]'

        # NOTE ---------------------------------------------------------------------------------
        t._note :path => '//note' do |n|
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
          n.id_at :path => '@ID', :accessor => lambda { |a| a.text }
          n.type_at :path => '@type', :accessor => lambda { |a| a.text }
        end
        
        # ORIGIN_INFO --------------------------------------------------------------------------
        t.origin_info :path => '/mods/originInfo'
        t._origin_info :path => '//originInfo' do |n|
          n.place :path => 'place' do |e|
            e.placeTerm :path => 'placeTerm' do |ee|
              ee.type_at :path => '@type', :accessor => lambda { |a| a.text }
              Mods::AUTHORITY_ATTRIBS.each { |attr_name|
                ee.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
              }
            end
          end
          n.publisher :path => 'publisher'
          Mods::ORIGIN_INFO_DATE_ELEMENTS.each { |date_el|
            n.send date_el, :path => "#{date_el}" do |d|
              Mods::DATE_ATTRIBS.each { |attr_name|
                d.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
              }
              if date_el == 'dateOther'
                d.type_at :path => '@type', :accessor => lambda { |a| a.text }
              end
            end
          }
          n.edition :path => 'edition'
          n.issuance :path => 'issuance'
          n.frequency :path => 'frequency' do |f|
            Mods::AUTHORITY_ATTRIBS.each { |attr_name|
              f.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
          end
        end # t.origin_info
        
        # PART -----------------------------------------------------------------------------------
        t.part :path => '/mods/part'
        t._part :path => '//part' do |n|
          # attributes
          n.id_at :path => '@ID', :accessor => lambda { |a| a.text }
          n.order :path => '@order', :accessor => lambda { |a| a.text }
          n.type_at :path => '@type', :accessor => lambda { |a| a.text }
          # child elements
          n.detail :path => 'detail' do |e|
            # attributes
            e.level :path => '@level', :accessor => lambda { |a| a.text }
            e.type_at :path => '@type', :accessor => lambda { |a| a.text }
            # elements
            e.number :path => 'number'
            e.caption :path => 'caption'
            e.title :path => 'title'
          end
          n.extent :path => 'extent' do |e|  # TODO:  extent is ordered in xml schema
            # attributes
            e.unit :path => '@unit', :accessor => lambda { |a| a.text }
            # elements
            e.start :path => 'start'
            e.end :path => 'end'
            e.total :path => 'total'
            e.list :path => 'list'
          end
          n.date :path => 'date' do |e|  # TODO:  extent is ordered in xml schema
            Mods::DATE_ATTRIBS.reject { |a| a == 'keyDate' }.each { |attr_name|
              e.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
          end
          n.text_el :path => 'text' do |e|  
            e.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
            e.type_at :path => '@type', :accessor => lambda { |a| a.text }
          end
        end # t._part
        
        # PHYSICAL_DESCRIPTION -------------------------------------------------------------------
        t.physical_description :path => '/mods/physicalDescription'
        t._physical_description :path => '//physicalDescription' do |n|
          n.digitalOrigin :path => 'digitalOrigin'
          n.extent :path => 'extent'
          n.form :path => 'form' do |f|
            f.type_at :path => '@type', :accessor => lambda { |a| a.text }
            Mods::AUTHORITY_ATTRIBS.each { |attr_name|
              f.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
          end
          n.internetMediaType :path => 'internetMediaType'
          n.note :path => 'note' do |nn|
            nn.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
            nn.type_at :path => '@type', :accessor => lambda { |a| a.text }
          end
          n.reformattingQuality :path => 'reformattingQuality'
        end
        
        # RECORD_INFO --------------------------------------------------------------------------
        t.record_info :path => '/mods/recordInfo'
        t._record_info :path => '//recordInfo' do |n|
          # attributes
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
          Mods::LANG_ATTRIBS.each { |attr_name|
            n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
          # child elements
          n.recordContentSource :path => 'recordContentSource' do |r|
            Mods::AUTHORITY_ATTRIBS.each { |attr_name|
              r.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
          end
          n.recordCreationDate :path => 'recordCreationDate' do |r|
            Mods::DATE_ATTRIBS.each { |attr_name|
              r.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
          end
          n.recordChangeDate :path => 'recordChangeDate' do |r|
            Mods::DATE_ATTRIBS.each { |attr_name|
              r.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
          end
          n.recordIdentifier :path => 'recordIdentifier' do |r|
            r.source :path => '@source', :accessor => lambda { |a| a.text }
          end
          n.recordOrigin :path => 'recordOrigin'
          n.languageOfCataloging :path => 'languageOfCataloging' do |r|
            Mods::AUTHORITY_ATTRIBS.each { |attr_name|
              r.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
            r.languageTerm :path => 'languageTerm'
            r.scriptTerm :path => 'scriptTerm'
          end
          n.descriptionStandard :path => 'descriptionStandard' do |r|
            Mods::AUTHORITY_ATTRIBS.each { |attr_name|
              r.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
          end
        end # t._record_info
        
        # RELATED_ITEM-------------------------------------------------------------------------
        t.related_item :path => '/mods/relatedItem' do |n|
          # attributes
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
          n.id_at :path => '@ID', :accessor => lambda { |a| a.text }
          n.type_at :path => '@type', :accessor => lambda { |a| a.text }
          # elements
          n.abstract :path => 'abstract'
          n.accessCondition :path => 'accessCondition'
          n.classification :path => 'classification'
          n.extension :path => 'extension'
          n.genre :path => 'genre'
          n.identifier :path => 'identifier'
          n.language :path => 'language'
          n.location :path => 'location'
          n.name_el :path => 'name'
          n.note :path => 'note'
          n.originInfo :path => 'originInfo'
          n.part :path => 'part'
          n.physicalDescription :path => 'physicalDescription'
          n.recordInfo :path => 'recordInfo'
          n.subject :path => 'subject'
          n.tableOfContents :path => 'tableOfContents'
          n.targetAudience :path => 'targetAudience'
          n.titleInfo :path => 'titleInfo'
          n.typeOfResource :path => 'typeOfResource'
        end

        # SUBJECT -----------------------------------------------------------------------------
        t.subject :path => '/mods/subject'
        t._subject :path => '//subject' do |n|
          Mods::AUTHORITY_ATTRIBS.each { |attr_name|
            n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
          n.topic :path => 'topic' do |n|
            Mods::AUTHORITY_ATTRIBS.each { |attr_name|
              n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
          end
          n.geographic :path => 'geographic' do |n|
            Mods::AUTHORITY_ATTRIBS.each { |attr_name|
              n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
          end
          n.temporal :path => 'temporal' do |n|
            # date attributes as elements
            Mods::DATE_ATTRIBS.each { |attr_name|
              n.send attr_name, :path => "#{attr_name}"
            }
            Mods::AUTHORITY_ATTRIBS.each { |attr_name|
              n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
            # date attributes as attributes
            Mods::DATE_ATTRIBS.each { |attr_name|
              n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
          end
          n.titleInfo :path => 'titleInfo' do |t|
            Mods::AUTHORITY_ATTRIBS.each { |attr_name|
              t.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
          end
          # Note:  'name' is used by Nokogiri
          n.name_ :path => 'name' do |t|
            Mods::AUTHORITY_ATTRIBS.each { |attr_name|
              t.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
          end
          n.geographicCode :path => 'geographicCode' do |g|
            Mods::AUTHORITY_ATTRIBS.each { |attr_name|
              g.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
          end
          n.genre :path => 'genre' do |n|
            Mods::AUTHORITY_ATTRIBS.each { |attr_name|
              n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
          end
          n.hierarchicalGeographic :path => 'hierarchicalGeographic' do |n|
            Mods::Subject::HIER_GEO_CHILD_ELEMENTS.each { |elname|
              n.send elname, :path => "#{elname}"
            }
            Mods::AUTHORITY_ATTRIBS.each { |attr_name|
              n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
          end
          n.cartographics :path => 'cartographics' do |n|
            n.scale :path => 'scale'
            n.projection :path => 'projection'
            n.coordinates :path => 'coordinates'
            Mods::Subject::CARTOGRAPHICS_CHILD_ELEMENTS.each { |elname|
              n.send elname, :path => "#{elname}"
            }
          end
          n.occupation :path => 'occupation' do |n|
            Mods::AUTHORITY_ATTRIBS.each { |attr_name|
              n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
          end
        end # t.subject
        
        # TABLE_OF_CONTENTS ---------------------------------------------------------------------
        t._tableOfContents :path => '//tableOfContents' do |n|
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
          n.shareable :path => '@shareable', :accessor => lambda { |a| a.text }
          n.type_at :path => '@type', :accessor => lambda { |a| a.text }
        end
        
        # TARGET_AUDIENCE -----------------------------------------------------------------------
        t._targetAudience :path => '//targetAudience' do |n|
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
          Mods::AUTHORITY_ATTRIBS.each { |attr_name|
            n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
        end
        
        # TITLE_INFO ----------------------------------------------------------------------------
        t.title_info :path => '/mods/titleInfo'
        t._title_info :path => '//titleInfo' do |n|
          Mods::TitleInfo::ATTRIBUTES.each { |attr_name|
            if attr_name != 'type'
              n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            else
              n.type_at :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            end
          }          
          n.title :path => 'title'
          n.subTitle :path => 'subTitle'
          n.nonSort :path => 'nonSort'
          n.partNumber :path => 'partNumber'
          n.partName :path => 'partName'
          n.sort_title :path => '.', :accessor => lambda { |node| 
            if node.type_at != "alternative" || (node.type_at == "alternative" && mods_ng_xml.xpath('/mods/titleInfo').size == 1)
              node.title.text + (!node.subTitle.text.empty? ? "#{@title_delimiter}#{node.subTitle.text}" : "" ) 
            end
          }
          n.full_title :path => '.', :accessor => lambda { |node| 
             (!node.nonSort.text.empty? ? "#{node.nonSort.text} " : "" ) + 
             node.title.text + 
             (!node.subTitle.text.empty? ? "#{@title_delimiter}#{node.subTitle.text}" : "" ) 
          }
          n.short_title :path => '.', :accessor => lambda { |node|  
            if node.type_at != "alternative"
              (!node.nonSort.text.empty? ? "#{node.nonSort.text} " : "" ) + 
              node.title.text
            end
          }
          n.alternative_title :path => '.', :accessor => lambda { |node|  
            if node.type_at == "alternative"
              (!node.nonSort.text.empty? ? "#{node.nonSort.text} " : "" ) + 
              node.title.text
            end
          }
        end # t._title_info
        
        # TYPE_OF_RESOURCE --------------------------------------------------------------------
        t._typeOfResource :path => '//typeOfResource' do |n|
          n.collection :path => '@collection', :accessor => lambda { |a| a.text }
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
          n.manuscript :path => '@manuscript', :accessor => lambda { |a| a.text }
          n.usage :path => '@usage', :accessor => lambda { |a| a.text }
        end
        
      end # terminology

      mods_ng_xml.nom!

      mods_ng_xml
    end # set_terminology_no_ns


    # set the NOM terminology, with namespaces
    # @param mods_ng_xml a Nokogiri::Xml::Document object containing MODS (with namespaces)
    def set_terminology_ns(mods_ng_xml)
      mods_ng_xml.set_terminology(:namespaces => { 'm' => Mods::MODS_NS}) do |t|

        # TODO  implement terminology with namespace

      end
      
      mods_ng_xml.nom!
      
      mods_ng_xml
    end # set_terminology_ns
    
  end
  
end

