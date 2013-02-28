module Mods
  
  # from:  http://www.loc.gov/standards/mods/v3/mods-userguide-generalapp.html
  
  # FIXME: didn't figure out a good way to deal with namespaced attribute for non-namespaced terminology
#  LANG_ATTRIBS = ['lang', 'xml:lang', 'script', 'transliteration']
  LANG_ATTRIBS = ['lang', 'script', 'transliteration']
  
  LINKING_ATTRIBS = ['xlink', 'ID']

  DATE_ATTRIBS = ['encoding', 'point', 'keyDate', 'qualifier']
  ENCODING_ATTRIB_VALUES = ['w3cdtf', 'iso8601', 'marc', 'edtf', 'temper']
  POINT_ATTRIB_VALUES = ['start', 'end']
  KEY_DATE_ATTRIB_VALUES = ['yes']
  QUALIFIER_ATTRIB_VALUES = ['approximate', 'inferred', 'questionable']
  
  AUTHORITY_ATTRIBS = ['authority', 'authorityURI', 'valueURI']

  class Record
    
    # set the NOM terminology;  WITH namespaces
    # NOTES:
    # 1.  certain words, such as 'type' 'name' 'description' are reserved words in jruby or nokogiri
    #  when the terminology would use these words, a suffix of '_at' is added if it is an attribute, 
    #  (e.g. 'type_at' for @type) and a suffix of '_el' is added if it is an element.
    # 2.  the underscore prefix variant terms are a way of making subterms for a node available 
    #   to any instance of said node and are not intended to be used externally
    # @param mods_ng_xml a Nokogiri::Xml::Document object containing MODS (with namespaces)
    def set_terminology_ns(mods_ng_xml)
      mods_ng_xml.set_terminology(:namespaces => { 'm' => Mods::MODS_NS }) do |t|

# FIXME: may want to deal with camelcase vs. underscore in method_missing 

        # ABSTRACT -------------------------------------------------------------------------------
        t.abstract :path => '/m:mods/m:abstract'
        t._abstract :path => '//m:abstract' do |n|
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
          n.type_at :path => '@type', :accessor => lambda { |a| a.text }
          Mods::LANG_ATTRIBS.each { |attr_name|
            n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
        end

        # ACCESS_CONDITION -----------------------------------------------------------------------
        t.accessCondition :path => '/m:mods/m:accessCondition'
        t._accessCondition :path => '//m:accessCondition' do |n|
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
          n.type_at :path => '@type', :accessor => lambda { |a| a.text }
          Mods::LANG_ATTRIBS.each { |attr_name|
            n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
        end

        # CLASSIFICATION -------------------------------------------------------------------------
        t.classification :path => '/m:mods/m:classification'
        t._classification :path => '//m:classification' do |n|
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
          n.edition :path => '@edition', :accessor => lambda { |a| a.text }
          Mods::AUTHORITY_ATTRIBS.each { |attr_name|
            n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
          Mods::LANG_ATTRIBS.each { |attr_name|
            n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
        end        

        # EXTENSION ------------------------------------------------------------------------------
        t.extension :path => '/m:mods/m:extension'
        t._extension :path => '//m:extension' do |n|
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
        end

        # GENRE ----------------------------------------------------------------------------------
        t.genre :path => '/m:mods/m:genre'
        t._genre :path => '//m:genre' do |n|
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
          n.type_at :path => '@type', :accessor => lambda { |a| a.text }
          n.usage :path => '@usage', :accessor => lambda { |a| a.text }
          Mods::AUTHORITY_ATTRIBS.each { |attr_name|
            n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
          Mods::LANG_ATTRIBS.each { |attr_name|
            n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
        end

        # IDENTIIER ------------------------------------------------------------------------------
        t.identifier :path => '/m:mods/m:identifier'
        t._identifier :path => '//m:identifier' do |n|
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
          n.invalid :path => '@invalid', :accessor => lambda { |a| a.text }
          n.type_at :path => '@type', :accessor => lambda { |a| a.text }
          Mods::LANG_ATTRIBS.each { |attr_name|
            n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
        end

        # LANGUAGE -------------------------------------------------------------------------------
        t.language :path => '/m:mods/m:language'
        t._language :path => '//m:language' do |n|
          # attributes
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
          Mods::LANG_ATTRIBS.each { |attr_name|
            n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
          # child elements
          n.languageTerm :path => 'm:languageTerm'
          n.code_term :path => 'm:languageTerm[@type="code"]'
          n.text_term :path => 'm:languageTerm[@type="text"]'
          n.scriptTerm :path => 'm:scriptTerm'
        end
        t._languageTerm :path => '//m:languageTerm' do |lt|
          lt.type_at :path => '@type', :accessor => lambda { |a| a.text }
          Mods::AUTHORITY_ATTRIBS.each { |attr_name|
            lt.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
        end # t.language

        # LOCATION -------------------------------------------------------------------------------
        t.location :path => '/m:mods/m:location'
        t._location :path => '//m:location' do |n|
          # attributes
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
          Mods::LANG_ATTRIBS.each { |attr_name|
            n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
          # child elements
          n.physicalLocation :path => 'm:physicalLocation' do |e|
            e.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
            Mods::AUTHORITY_ATTRIBS.each { |attr_name|
              e.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
          end
          n.shelfLocator :path => 'm:shelfLocator'
          n.url :path => 'm:url' do |e|
            e.dateLastAccessed :path => '@dateLastAccessed', :accessor => lambda { |a| a.text }
            e.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
            e.note :path => '@note', :accessor => lambda { |a| a.text }
            e.access :path => '@access', :accessor => lambda { |a| a.text }
            e.usage :path => '@usage', :accessor => lambda { |a| a.text }
          end
          n.holdingSimple :path => 'm:holdingSimple'
          n.holdingExternal :path => 'm:holdingExternal'
        end # t.location

        # NAME ------------------------------------------------------------------------------------
        t.plain_name :path => '/m:mods/m:name'
        t._plain_name :path => '//m:name' do |n|
          Mods::Name::ATTRIBUTES.each { |attr_name|
            if attr_name != 'type'
              n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            else
              n.type_at :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            end
          }
          # elements
          n.namePart :path => 'm:namePart' do |np|
            np.type_at :path => '@type', :accessor => lambda { |a| a.text }
          end
          n.family_name :path => 'm:namePart[@type="family"]'
          n.given_name :path => 'm:namePart[@type="given"]'
          n.termsOfAddress :path => 'm:namePart[@type="termsOfAddress"]'
          n.date :path => 'm:namePart[@type="date"]'
          
          n.displayForm :path => 'm:displayForm'
          n.affiliation :path => 'm:affiliation'
          n.description_el :path => 'm:description' # description is used by Nokogiri
          n.role :path => 'm:role' do |r| 
            r.roleTerm :path => 'm:roleTerm' do |rt|
              rt.type_at :path => "@type", :accessor => lambda { |a| a.text }
              Mods::AUTHORITY_ATTRIBS.each { |attr_name|
                rt.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
              }
            end
            # role convenience method
            r.authority :path => '.', :accessor => lambda { |role_node| 
              a = nil
              role_node.roleTerm.each { |role_t|
                # role_t.authority will be [] if it is missing from an earlier roleTerm
                if role_t.authority && (!a || a.size == 0)
                  a = role_t.authority
                end
              }
              a
            }
            # role convenience method            
            r.code :path => '.', :accessor => lambda { |role_node| 
              c = nil
              role_node.roleTerm.each { |role_t|  
                if role_t.type_at == 'code'
                  c ||= role_t.text
                end
              }
              c
            }
            # role convenience method
            r.value :path => '.', :accessor => lambda { |role_node| 
              val = nil
              role_node.roleTerm.each { |role_t|  
                if role_t.type_at == 'text'
                  val ||= role_t.text
                end
              }
              # FIXME:  this is broken if there are multiple role codes and some of them are not marcrelator
              if !val && role_node.code && role_node.authority.first =~ /marcrelator/
                val = MARC_RELATOR[role_node.code.first]
              end
              val
            }
          end # role node
          
          # name convenience method
          # uses the displayForm of a name if present
          #   if no displayForm, try to make a string from family, given and terms of address
          #   otherwise, return all non-date nameParts concatenated together
          n.display_value :path => '.', :single => true, :accessor => lambda {|name_node|
            dv = ''
            if name_node.displayForm && name_node.displayForm.text.size > 0
              dv = name_node.displayForm.text
            end
            if dv.empty?
              if name_node.type_at == 'personal'
                if name_node.family_name.size > 0
                  dv = name_node.given_name.size > 0 ? "#{name_node.family_name.text}, #{name_node.given_name.text}" : name_node.family_name.text
                elsif name_node.given_name.size > 0
                  dv = name_node.given_name.text
                end
                if !dv.empty?
                  first = true
                  name_node.namePart.each { |np| 
                    if np.type_at == 'termsOfAddress' && !np.text.empty?
                      if first
                        dv = dv + " " + np.text
                        first = false
                      else
                        dv = dv + ", " + np.text
                      end
                    end
                  }
                else # no family or given name 
                  dv = name_node.namePart.select {|np| np.type_at != 'date' && !np.text.empty?}.join(" ")
                end
              else # not a personal name
                dv = name_node.namePart.select {|np| np.type_at != 'date' && !np.text.empty?}.join(" ")
              end
            end
            dv.strip.empty? ? nil : dv.strip
          }
          
          # name convenience method
          n.display_value_w_date :path => '.', :single => true, :accessor => lambda {|name_node|
            dv = '' 
            dv = dv + name_node.display_value if name_node.display_value
            name_node.namePart.each { |np|  
              if np.type_at == 'date' && !np.text.empty? && !dv.end_with?(np.text)
                dv = dv + ", #{np.text}"
              end
            }
            if dv.start_with?(', ')
              dv.sub(', ', '')
            end
            dv.strip.empty? ? nil : dv.strip
          }
        end # t._plain_name

        t.personal_name :path => '/m:mods/m:name[@type="personal"]'
        t._personal_name :path => '//m:name[@type="personal"]'
        t.corporate_name :path => '/m:mods/m:name[@type="corporate"]'
        t._corporate_name :path => '//m:name[@type="corporate"]'
        t.conference_name :path => '/m:mods/m:name[@type="conference"]'
        t._conference_name :path => '//m:name[@type="conference"]'

        # NOTE ---------------------------------------------------------------------------------
        t.note :path => '/m:mods/m:note'
        t._note :path => '//m:note' do |n|
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
          n.id_at :path => '@ID', :accessor => lambda { |a| a.text }
          n.type_at :path => '@type', :accessor => lambda { |a| a.text }
          Mods::LANG_ATTRIBS.each { |attr_name|
            n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
        end

        # ORIGIN_INFO --------------------------------------------------------------------------
        t.origin_info :path => '/m:mods/m:originInfo'
        t._origin_info :path => '//m:originInfo' do |n|
          # attributes
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
          Mods::LANG_ATTRIBS.each { |attr_name|
            n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
          # child elements
          n.place :path => 'm:place' do |e|
            e.placeTerm :path => 'm:placeTerm' do |ee|
              ee.type_at :path => '@type', :accessor => lambda { |a| a.text }
              Mods::AUTHORITY_ATTRIBS.each { |attr_name|
                ee.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
              }
            end
          end
          n.publisher :path => 'm:publisher'
          Mods::ORIGIN_INFO_DATE_ELEMENTS.each { |date_el|
            n.send date_el, :path => "m:#{date_el}" do |d|
              Mods::DATE_ATTRIBS.each { |attr_name|
                d.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
              }
              if date_el == 'dateOther'
                d.type_at :path => '@type', :accessor => lambda { |a| a.text }
              end
            end
          }
          n.edition :path => 'm:edition'
          n.issuance :path => 'm:issuance'
          n.frequency :path => 'm:frequency' do |f|
            Mods::AUTHORITY_ATTRIBS.each { |attr_name|
              f.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
          end
        end # t.origin_info

        # PART -----------------------------------------------------------------------------------
        t.part :path => '/m:mods/m:part'
        t._part :path => '//m:part' do |n|
          # attributes
          n.id_at :path => '@ID', :accessor => lambda { |a| a.text }
          n.order :path => '@order', :accessor => lambda { |a| a.text }
          n.type_at :path => '@type', :accessor => lambda { |a| a.text }
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
          Mods::LANG_ATTRIBS.each { |attr_name|
            n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
          # child elements
          n.detail :path => 'm:detail' do |e|
            # attributes
            e.level :path => '@level', :accessor => lambda { |a| a.text }
            e.type_at :path => '@type', :accessor => lambda { |a| a.text }
            # elements
            e.number :path => 'm:number'
            e.caption :path => 'm:caption'
            e.title :path => 'm:title'
          end
          n.extent :path => 'm:extent' do |e|  # TODO:  extent is ordered in xml schema
            # attributes
            e.unit :path => '@unit', :accessor => lambda { |a| a.text }
            # elements
            e.start :path => 'm:start'
            e.end :path => 'm:end'
            e.total :path => 'm:total'
            e.list :path => 'm:list'
          end
          n.date :path => 'm:date' do |e| 
            Mods::DATE_ATTRIBS.reject { |a| a == 'keyDate' }.each { |attr_name|
              e.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
          end
          n.text_el :path => 'm:text' do |e|  
            e.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
            e.type_at :path => '@type', :accessor => lambda { |a| a.text }
          end
        end # t._part

        # PHYSICAL_DESCRIPTION -------------------------------------------------------------------
        t.physical_description :path => '/m:mods/m:physicalDescription'
        t._physical_description :path => '//m:physicalDescription' do |n|
          # attributes
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
          Mods::LANG_ATTRIBS.each { |attr_name|
            n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
          # child elements
          n.digitalOrigin :path => 'm:digitalOrigin'
          n.extent :path => 'm:extent'
          n.form :path => 'm:form' do |f|
            f.type_at :path => '@type', :accessor => lambda { |a| a.text }
            Mods::AUTHORITY_ATTRIBS.each { |attr_name|
              f.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
          end
          n.internetMediaType :path => 'm:internetMediaType'
          n.note :path => 'm:note' do |nn|
            nn.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
            nn.type_at :path => '@type', :accessor => lambda { |a| a.text }
          end
          n.reformattingQuality :path => 'm:reformattingQuality'
        end

        # RECORD_INFO --------------------------------------------------------------------------
        t.record_info :path => '/m:mods/m:recordInfo'
        t._record_info :path => '//m:recordInfo' do |n|
          # attributes
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
          Mods::LANG_ATTRIBS.each { |attr_name|
            n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
          # child elements
          n.recordContentSource :path => 'm:recordContentSource' do |r|
            Mods::AUTHORITY_ATTRIBS.each { |attr_name|
              r.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
          end
          n.recordCreationDate :path => 'm:recordCreationDate' do |r|
            Mods::DATE_ATTRIBS.each { |attr_name|
              r.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
          end
          n.recordChangeDate :path => 'm:recordChangeDate' do |r|
            Mods::DATE_ATTRIBS.each { |attr_name|
              r.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
          end
          n.recordIdentifier :path => 'm:recordIdentifier' do |r|
            r.source :path => '@source', :accessor => lambda { |a| a.text }
          end
          n.recordOrigin :path => 'm:recordOrigin'
          n.languageOfCataloging :path => 'm:languageOfCataloging' do |r|
            Mods::AUTHORITY_ATTRIBS.each { |attr_name|
              r.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
            r.languageTerm :path => 'm:languageTerm'
            r.scriptTerm :path => 'm:scriptTerm'
          end
          n.descriptionStandard :path => 'm:descriptionStandard' do |r|
            Mods::AUTHORITY_ATTRIBS.each { |attr_name|
              r.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
          end
        end # t._record_info

        # RELATED_ITEM-------------------------------------------------------------------------
        t.related_item :path => '/m:mods/m:relatedItem' do |n|
          # attributes
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
          n.id_at :path => '@ID', :accessor => lambda { |a| a.text }
          n.type_at :path => '@type', :accessor => lambda { |a| a.text }
          # elements
          n.abstract :path => 'abstract'
          n.accessCondition :path => 'm:accessCondition'
          n.classification :path => 'm:classification'
          n.extension :path => 'm:extension'
          n.genre :path => 'm:genre'
          n.identifier :path => 'm:identifier'
          n.language :path => 'm:language'
          n.location :path => 'm:location'
          n.name_el :path => 'm:name'  # Note:  'name' is used by Nokogiri
          n.personal_name :path => 'm:name[@type="personal"]'
          n.corporate_name :path => 'm:name[@type="corporate"]'
          n.conference_name :path => 'm:name[@type="conference"]'
          n.note :path => 'm:note'
          n.originInfo :path => 'm:originInfo'
          n.part :path => 'm:part'
          n.physicalDescription :path => 'm:physicalDescription'
          n.recordInfo :path => 'm:recordInfo'
          n.subject :path => 'm:subject'
          n.tableOfContents :path => 'm:tableOfContents'
          n.targetAudience :path => 'm:targetAudience'
          n.titleInfo :path => 'm:titleInfo'
          n.typeOfResource :path => 'm:typeOfResource'
        end

        # SUBJECT -----------------------------------------------------------------------------
        t.subject :path => '/m:mods/m:subject'
        t._subject :path => '//m:subject' do |n|
          # attributes
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
          Mods::AUTHORITY_ATTRIBS.each { |attr_name|
            n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
          Mods::LANG_ATTRIBS.each { |attr_name|
            n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
          # child elements
          n.cartographics :path => 'm:cartographics' do |n1|
            n1.scale :path => 'm:scale'
            n1.projection :path => 'm:projection'
            n1.coordinates :path => 'm:coordinates'
            Mods::Subject::CARTOGRAPHICS_CHILD_ELEMENTS.each { |elname|
              n1.send elname, :path => "m:#{elname}"
            }
          end
          n.genre :path => 'm:genre' do |n1|
            Mods::AUTHORITY_ATTRIBS.each { |attr_name|
              n1.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
          end
          n.geographic :path => 'm:geographic' do |n1|
            Mods::AUTHORITY_ATTRIBS.each { |attr_name|
              n1.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
          end
          n.geographicCode :path => 'm:geographicCode' do |gc|
            Mods::AUTHORITY_ATTRIBS.each { |attr_name|
              gc.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
            # convenience method
            gc.translated_value :path => '.', :accessor => lambda { |gc_node| 
              code_val ||= gc_node.text
              xval = nil
              if code_val
                case gc_node.authority
                  when 'marcgac'
                    xval = MARC_GEOGRAPHIC_AREA[code_val]
                  when 'marccountry'
                    xval = MARC_COUNTRY[code_val]
                end
              end
              xval
            }
          end
          n.hierarchicalGeographic :path => 'm:hierarchicalGeographic' do |n1|
            Mods::Subject::HIER_GEO_CHILD_ELEMENTS.each { |elname|
              n1.send elname, :path => "m:#{elname}"
            }
            Mods::AUTHORITY_ATTRIBS.each { |attr_name|
              n1.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
          end
          # Note:  'name' is used by Nokogiri
          n.name_el :path => 'm:name' do |t1|
            Mods::AUTHORITY_ATTRIBS.each { |attr_name|
              t1.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
          end
          n.personal_name :path => 'm:name[@type="personal"]'
          n.corporate_name :path => 'm:name[@type="corporate"]'
          n.conference_name :path => 'm:name[@type="conference"]'
          n.occupation :path => 'm:occupation' do |n1|
            Mods::AUTHORITY_ATTRIBS.each { |attr_name|
              n1.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
          end
          n.temporal :path => 'm:temporal' do |n1|
            Mods::AUTHORITY_ATTRIBS.each { |attr_name|
              n1.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
            # date attributes as attributes
            Mods::DATE_ATTRIBS.each { |attr_name|
              n1.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
          end
          n.titleInfo :path => 'm:titleInfo' do |t1|
            Mods::AUTHORITY_ATTRIBS.each { |attr_name|
              t1.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
          end
          n.topic :path => 'm:topic' do |n1|
            Mods::AUTHORITY_ATTRIBS.each { |attr_name|
              n1.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
          end
        end # t.subject

        # TABLE_OF_CONTENTS ---------------------------------------------------------------------
        t.tableOfContents :path => '/m:mods/m:tableOfContents'
        t._tableOfContents :path => '//m:tableOfContents' do |n|
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
          n.shareable :path => '@shareable', :accessor => lambda { |a| a.text }
          n.type_at :path => '@type', :accessor => lambda { |a| a.text }
          Mods::LANG_ATTRIBS.each { |attr_name|
            n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
        end

        # TARGET_AUDIENCE -----------------------------------------------------------------------
        t.targetAudience :path => '/m:mods/m:targetAudience'
        t._targetAudience :path => '//m:targetAudience' do |n|
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
          Mods::AUTHORITY_ATTRIBS.each { |attr_name|
            n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
          Mods::LANG_ATTRIBS.each { |attr_name|
            n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
        end

        # TITLE_INFO ----------------------------------------------------------------------------
        t.title_info :path => '/m:mods/m:titleInfo'
        t._title_info :path => '//m:titleInfo' do |n|
          Mods::TitleInfo::ATTRIBUTES.each { |attr_name|
            if attr_name != 'type'
              n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            else
              n.type_at :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            end
          }          
          n.title :path => 'm:title'
          n.subTitle :path => 'm:subTitle'
          n.nonSort :path => 'm:nonSort'
          n.partNumber :path => 'm:partNumber'
          n.partName :path => 'm:partName'
          # convenience method
          n.sort_title :path => '.', :accessor => lambda { |node| 
            if node.type_at != "alternative" || (node.type_at == "alternative" && 
                  mods_ng_xml.xpath('/m:mods/m:titleInfo', {'m' => Mods::MODS_NS}).size == 1)
              node.title.text + (!node.subTitle.text.empty? ? "#{@title_delimiter}#{node.subTitle.text}" : "" ) 
            end
          }
          # convenience method
          n.full_title :path => '.', :accessor => lambda { |node| 
             (!node.nonSort.text.empty? ? "#{node.nonSort.text} " : "" ) + 
             node.title.text + 
             (!node.subTitle.text.empty? ? "#{@title_delimiter}#{node.subTitle.text}" : "" ) 
          }
          # convenience method
          n.short_title :path => '.', :accessor => lambda { |node|  
            if node.type_at != "alternative"
              (!node.nonSort.text.empty? ? "#{node.nonSort.text} " : "" ) + 
              node.title.text
            end
          }
          # convenience method
          n.alternative_title :path => '.', :accessor => lambda { |node|  
            if node.type_at == "alternative"
              (!node.nonSort.text.empty? ? "#{node.nonSort.text} " : "" ) + 
              node.title.text
            end
          }
        end # t._title_info

        # TYPE_OF_RESOURCE --------------------------------------------------------------------
        t.typeOfResource :path => '/m:mods/m:typeOfResource'
        t._typeOfResource :path => '//m:typeOfResource' do |n|
          n.collection :path => '@collection', :accessor => lambda { |a| a.text }
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
          n.manuscript :path => '@manuscript', :accessor => lambda { |a| a.text }
          n.usage :path => '@usage', :accessor => lambda { |a| a.text }
        end

      end # terminology
      
      mods_ng_xml.nom!      
      mods_ng_xml
    end # set_terminology_ns
    
    # set the NOM terminology;  do NOT use namespaces
    # NOTES:
    # 1.  certain words, such as 'type' 'name' 'description' are reserved words in jruby or nokogiri
    #  when the terminology would use these words, a suffix of '_at' is added if it is an attribute, 
    #  (e.g. 'type_at' for @type) and a suffix of '_el' is added if it is an element.
    # 2.  the underscore prefix variant terms are a way of making subterms for a node available 
    #   to any instance of said node and are not intended to be used externally
    # @param mods_ng_xml a Nokogiri::Xml::Document object containing MODS (without namespaces)
    def set_terminology_no_ns(mods_ng_xml)
      mods_ng_xml.set_terminology() do |t|

# FIXME: may want to deal with camelcase vs. underscore in method_missing 

        # ABSTRACT -------------------------------------------------------------------------------
        t.abstract :path => '/mods/abstract'
        t._abstract :path => '//abstract' do |n|
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
          n.type_at :path => '@type', :accessor => lambda { |a| a.text }
          Mods::LANG_ATTRIBS.each { |attr_name|
            n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
        end

        # ACCESS_CONDITION -----------------------------------------------------------------------
        t.accessCondition :path => '/mods/accessCondition'
        t._accessCondition :path => '//accessCondition' do |n|
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
          n.type_at :path => '@type', :accessor => lambda { |a| a.text }
          Mods::LANG_ATTRIBS.each { |attr_name|
            n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
        end

        # CLASSIFICATION -------------------------------------------------------------------------
        t.classification :path => '/mods/classification'
        t._classification :path => '//classification' do |n|
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
          n.edition :path => '@edition', :accessor => lambda { |a| a.text }
          Mods::AUTHORITY_ATTRIBS.each { |attr_name|
            n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
          Mods::LANG_ATTRIBS.each { |attr_name|
            n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
        end        

        # EXTENSION ------------------------------------------------------------------------------
        t.extension :path => '/mods/extension'
        t._extension :path => '//extension' do |n|
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
        end

        # GENRE ----------------------------------------------------------------------------------
        t.genre :path => '/mods/genre'
        t._genre :path => '//genre' do |n|
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
          n.type_at :path => '@type', :accessor => lambda { |a| a.text }
          n.usage :path => '@usage', :accessor => lambda { |a| a.text }
          Mods::AUTHORITY_ATTRIBS.each { |attr_name|
            n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
          Mods::LANG_ATTRIBS.each { |attr_name|
            n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
        end

        # IDENTIIER ------------------------------------------------------------------------------
        t.identifier :path => '/mods/identifier'
        t._identifier :path => '//identifier' do |n|
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
          n.invalid :path => '@invalid', :accessor => lambda { |a| a.text }
          n.type_at :path => '@type', :accessor => lambda { |a| a.text }
          Mods::LANG_ATTRIBS.each { |attr_name|
            n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
        end

        # LANGUAGE -------------------------------------------------------------------------------
        t.language :path => '/mods/language'
        t._language :path => '//language' do |n|
          # attributes
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
          Mods::LANG_ATTRIBS.each { |attr_name|
            n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
          # child elements
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
          # attributes
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
          Mods::LANG_ATTRIBS.each { |attr_name|
            n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
          # child elements
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
          n.family_name :path => 'namePart[@type="family"]'
          n.given_name :path => 'namePart[@type="given"]'
          n.termsOfAddress :path => 'namePart[@type="termsOfAddress"]'
          n.date :path => 'namePart[@type="date"]'

          n.displayForm :path => 'displayForm'
          n.affiliation :path => 'affiliation'
          n.description_el :path => 'description' # description is used by Nokogiri
          n.role :path => 'role' do |r| 
            r.roleTerm :path => 'roleTerm' do |rt|
              rt.type_at :path => "@type", :accessor => lambda { |a| a.text }
              Mods::AUTHORITY_ATTRIBS.each { |attr_name|
                rt.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
              }
            end
            # convenience method
            r.authority :path => '.', :accessor => lambda { |role_node| 
              a = nil
              role_node.roleTerm.each { |role_t| 
                # role_t.authority will be [] if it is missing from an earlier roleTerm
                if role_t.authority && (!a || a.size == 0)
                  a = role_t.authority
                end
              }
              a
            }
            # convenience method            
            r.code :path => '.', :accessor => lambda { |role_node| 
              c = nil
              role_node.roleTerm.each { |role_t|  
                if role_t.type_at == 'code' 
                  c ||= role_t.text
                end
              }
              c
            }
            # convenience method
            r.value :path => '.', :accessor => lambda { |role_node| 
              val = nil
              role_node.roleTerm.each { |role_t|  
                if role_t.type_at == 'text' 
                  val ||= role_t.text
                end
              }
              # FIXME:  this is broken if there are multiple role codes and some of them are not marcrelator
              if !val && role_node.code && role_node.authority.first =~ /marcrelator/
                val = MARC_RELATOR[role_node.code.first]
              end
              val
            }
          end # role node

          # name convenience method
          # uses the displayForm of a name if present
          #   if no displayForm, try to make a string from family, given and terms of address
          #   otherwise, return all non-date nameParts concatenated together
          n.display_value :path => '.', :single => true, :accessor => lambda {|name_node|
            dv = ''
            if name_node.displayForm && name_node.displayForm.text.size > 0
              dv = name_node.displayForm.text
            end
            if dv.empty?
              if name_node.type_at == 'personal'
                if name_node.family_name.size > 0
                  dv = name_node.given_name.size > 0 ? "#{name_node.family_name.text}, #{name_node.given_name.text}" : name_node.family_name.text
                elsif name_node.given_name.size > 0
                  dv = name_node.given_name.text
                end
                if !dv.empty?
                  first = true
                  name_node.namePart.each { |np| 
                    if np.type_at == 'termsOfAddress' && !np.text.empty?
                      if first
                        dv = dv + " " + np.text
                        first = false
                      else
                        dv = dv + ", " + np.text
                      end
                    end
                  }
                else # no family or given name
                  dv = name_node.namePart.select {|np| np.type_at != 'date' && !np.text.empty?}.join(" ")
                end
              else # not a personal name
                dv = name_node.namePart.select {|np| np.type_at != 'date' && !np.text.empty?}.join(" ")
              end
            end
            dv.strip.empty? ? nil : dv.strip
          }
          
          # name convenience method
          n.display_value_w_date :path => '.', :single => true, :accessor => lambda {|name_node|
            dv = '' + name_node.display_value
            name_node.namePart.each { |np|  
              if np.type_at == 'date' && !np.text.empty? && !dv.end_with?(np.text)
                dv = dv + ", #{np.text}"
              end
            }
            if dv.start_with?(', ')
              dv.sub(', ', '')
            end
            dv.strip.empty? ? nil : dv.strip
          }
        end # t._plain_name

        t.personal_name :path => '/mods/name[@type="personal"]'
        t._personal_name :path => '//name[@type="personal"]'
        t.corporate_name :path => '/mods/name[@type="corporate"]'
        t._corporate_name :path => '//name[@type="corporate"]'
        t.conference_name :path => '/mods/name[@type="conference"]'
        t._conference_name :path => '//name[@type="conference"]'

        # NOTE ---------------------------------------------------------------------------------
        t.note :path => '/mods/note'
        t._note :path => '//note' do |n|
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
          n.id_at :path => '@ID', :accessor => lambda { |a| a.text }
          n.type_at :path => '@type', :accessor => lambda { |a| a.text }
          Mods::LANG_ATTRIBS.each { |attr_name|
            n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
        end

        # ORIGIN_INFO --------------------------------------------------------------------------
        t.origin_info :path => '/mods/originInfo'
        t._origin_info :path => '//originInfo' do |n|
          # attributes
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
          Mods::LANG_ATTRIBS.each { |attr_name|
            n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
          # child elements
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
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
          Mods::LANG_ATTRIBS.each { |attr_name|
            n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
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
          n.date :path => 'date' do |e| 
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
          # attributes
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
          Mods::LANG_ATTRIBS.each { |attr_name|
            n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
          # child elements
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
          n.name_el :path => 'name'  # Note:  'name' is used by Nokogiri
          n.personal_name :path => 'name[@type="personal"]'
          n.corporate_name :path => 'name[@type="corporate"]'
          n.conference_name :path => 'name[@type="conference"]'
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
          # attributes
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
          Mods::AUTHORITY_ATTRIBS.each { |attr_name|
            n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
          Mods::LANG_ATTRIBS.each { |attr_name|
            n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
          # child elements
          n.cartographics :path => 'cartographics' do |n1|
            n1.scale :path => 'scale'
            n1.projection :path => 'projection'
            n1.coordinates :path => 'coordinates'
            Mods::Subject::CARTOGRAPHICS_CHILD_ELEMENTS.each { |elname|
              n1.send elname, :path => "#{elname}"
            }
          end
          n.geographic :path => 'geographic' do |n1|
            Mods::AUTHORITY_ATTRIBS.each { |attr_name|
              n1.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
          end
          n.genre :path => 'genre' do |n1|
            Mods::AUTHORITY_ATTRIBS.each { |attr_name|
              n1.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
          end
          n.geographicCode :path => 'geographicCode' do |gc|
            Mods::AUTHORITY_ATTRIBS.each { |attr_name|
              gc.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
            # convenience method
            gc.translated_value :path => '.', :accessor => lambda { |gc_node| 
              code_val ||= gc_node.text
              xval = nil
              if code_val
                case gc_node.authority
                  when 'marcgac'
                    xval = MARC_GEOGRAPHIC_AREA[code_val]
                  when 'marccountry'
                    xval = MARC_COUNTRY[code_val]
                end
              end
              xval
            }
          end
          n.hierarchicalGeographic :path => 'hierarchicalGeographic' do |n1|
            Mods::Subject::HIER_GEO_CHILD_ELEMENTS.each { |elname|
              n1.send elname, :path => "#{elname}"
            }
            Mods::AUTHORITY_ATTRIBS.each { |attr_name|
              n1.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
          end
          # Note:  'name' is used by Nokogiri
          n.name_el :path => 'name' do |t1|
            Mods::AUTHORITY_ATTRIBS.each { |attr_name|
              t1.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
          end
          n.personal_name :path => 'name[@type="personal"]'
          n.corporate_name :path => 'name[@type="corporate"]'
          n.conference_name :path => 'name[@type="conference"]'
          n.occupation :path => 'occupation' do |n1|
            Mods::AUTHORITY_ATTRIBS.each { |attr_name|
              n1.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
          end
          n.temporal :path => 'temporal' do |n1|
            Mods::AUTHORITY_ATTRIBS.each { |attr_name|
              n1.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
            # date attributes as attributes
            Mods::DATE_ATTRIBS.each { |attr_name|
              n1.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
          end
          n.titleInfo :path => 'titleInfo' do |t1|
            Mods::AUTHORITY_ATTRIBS.each { |attr_name|
              t1.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
          end
          n.topic :path => 'topic' do |n1|
            Mods::AUTHORITY_ATTRIBS.each { |attr_name|
              n1.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
          end
        end # t.subject

        # TABLE_OF_CONTENTS ---------------------------------------------------------------------
        t.tableOfContents :path => '/mods/tableOfContents'
        t._tableOfContents :path => '//tableOfContents' do |n|
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
          n.shareable :path => '@shareable', :accessor => lambda { |a| a.text }
          n.type_at :path => '@type', :accessor => lambda { |a| a.text }
          Mods::LANG_ATTRIBS.each { |attr_name|
            n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
        end

        # TARGET_AUDIENCE -----------------------------------------------------------------------
        t.targetAudience :path => '/mods/targetAudience'
        t._targetAudience :path => '//targetAudience' do |n|
          n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
          Mods::AUTHORITY_ATTRIBS.each { |attr_name|
            n.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
          }
          Mods::LANG_ATTRIBS.each { |attr_name|
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
        t.typeOfResource :path => '/mods/typeOfResource'
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

  end # Record class
end # Mods module

