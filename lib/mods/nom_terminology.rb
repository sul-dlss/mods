module Mods

  # from:  http://www.loc.gov/standards/mods/v3/mods-userguide-generalapp.html

  # Nokogiri 1.6.6 introduced lang as a built-in attribute
  LANG_ATTRIBS = ['script', 'transliteration']
  LINKING_ATTRIBS = ['xlink', 'ID']

  DATE_ATTRIBS = ['encoding', 'point', 'keyDate', 'qualifier']
  ENCODING_ATTRIB_VALUES = ['w3cdtf', 'iso8601', 'marc', 'edtf', 'temper']
  POINT_ATTRIB_VALUES = ['start', 'end']
  KEY_DATE_ATTRIB_VALUES = ['yes']
  QUALIFIER_ATTRIB_VALUES = ['approximate', 'inferred', 'questionable']

  AUTHORITY_ATTRIBS = ['authority', 'authorityURI', 'valueURI']

  class Record

    def with_attributes(element, attributes = [], method_mappings: { 'type' => 'type_at', 'ID' => 'id_at' })
      attributes.each do |attr_name|
        attr_method = method_mappings.fetch(attr_name, attr_name)
        element.send attr_method, path: "@#{attr_name}", accessor: lambda { |a| a.text }
      end
    end

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

        # ABSTRACT -------------------------------------------------------------------------------
        t.abstract  :path => '/m:mods/m:abstract'
        t._abstract :path => '//m:abstract' do |n|
          with_attributes(n, Mods::LANG_ATTRIBS | %w[displayLabel type])
        end

        # ACCESS_CONDITION -----------------------------------------------------------------------
        t.accessCondition  :path => '/m:mods/m:accessCondition'
        t._accessCondition :path => '//m:accessCondition' do |n|
          with_attributes(n, Mods::LANG_ATTRIBS | %w[displayLabel type])
        end

        # CLASSIFICATION -------------------------------------------------------------------------
        t.classification  :path => '/m:mods/m:classification'
        t._classification :path => '//m:classification' do |n|
          with_attributes(n, Mods::AUTHORITY_ATTRIBS | Mods::LANG_ATTRIBS | %w[displayLabel edition])
        end

        # EXTENSION ------------------------------------------------------------------------------
        t.extension  :path => '/m:mods/m:extension'
        t._extension :path => '//m:extension' do |n|
          with_attributes(n, %w[displayLabel])
        end

        # GENRE ----------------------------------------------------------------------------------
        t.genre  :path => '/m:mods/m:genre'
        t._genre :path => '//m:genre' do |n|
          with_attributes(n, Mods::AUTHORITY_ATTRIBS | Mods::LANG_ATTRIBS | %w[displayLabel type usage])
        end

        # IDENTIIER ------------------------------------------------------------------------------
        t.identifier  :path => '/m:mods/m:identifier'
        t._identifier :path => '//m:identifier' do |n|
          with_attributes(n, Mods::LANG_ATTRIBS | %w[displayLabel type invalid])
        end

        # LANGUAGE -------------------------------------------------------------------------------
        t.language  :path => '/m:mods/m:language'
        t._language :path => '//m:language' do |n|
          # attributes
          with_attributes(n, Mods::LANG_ATTRIBS | %w[displayLabel])
          # child elements
          n.languageTerm :path => 'm:languageTerm'
          n.code_term    :path => 'm:languageTerm[@type="code"]'
          n.text_term    :path => 'm:languageTerm[@type="text"]'
          n.scriptTerm   :path => 'm:scriptTerm'
        end
        t._languageTerm :path => '//m:languageTerm' do |lt|
          with_attributes(lt, Mods::AUTHORITY_ATTRIBS | %w[type])
        end # t.language

        # LOCATION -------------------------------------------------------------------------------
        t.location  :path => '/m:mods/m:location'
        t._location :path => '//m:location' do |n|
          # attributes
          with_attributes(n, Mods::LANG_ATTRIBS | %w[displayLabel])
          # child elements
          n.physicalLocation :path => 'm:physicalLocation' do |e|
            with_attributes(e, Mods::AUTHORITY_ATTRIBS | %w[displayLabel type])
          end
          n.shelfLocator :path => 'm:shelfLocator'
          n.url :path => 'm:url' do |e|
            with_attributes(e, %w[dateLastAccessed displayLabel note access usage])
          end
          n.holdingSimple :path => 'm:holdingSimple' do |h|
            h.copyInformation path: 'm:copyInformation' do |c|
              c.form path: 'm:form' do |f|
                with_attributes(f, Mods::LANG_ATTRIBS | %w[type])
              end
              c.sub_location path: 'm:subLocation' do |s|
                with_attributes(s, Mods::LANG_ATTRIBS)
              end

              c.shelf_locator path: 'm:shelfLocator' do |s|
                with_attributes(s, Mods::LANG_ATTRIBS)
              end
              c.electronic_locator path: 'm:electronicLocator'
              c.note path: 'm:note' do |note|
                with_attributes(note, Mods::LANG_ATTRIBS | %w[displayLabel type])
              end
              c.enumeration_and_chronology path: 'm:enumerationAndChronology' do |e|
                with_attributes(e, Mods::LANG_ATTRIBS | %w[unitType])
              end
              c.item_identifier path: 'm:itemIdentifier' do |i|
                with_attributes(i, %w[type])
              end
            end
          end
          n.holdingExternal :path => 'm:holdingExternal'
        end # t.location

        # NAME ------------------------------------------------------------------------------------
        t.plain_name  :path => '/m:mods/m:name'
        t._plain_name :path => '(//m:name|//m:alternativeName)' do |n|
          with_attributes(n, Mods::Name::ATTRIBUTES)
          # elements
          n.namePart :path => 'm:namePart' do |np|
            with_attributes(np, %w[type])
          end
          n.family_name    :path => 'm:namePart[@type="family"]'
          n.given_name     :path => 'm:namePart[@type="given"]'
          n.termsOfAddress :path => 'm:namePart[@type="termsOfAddress"]'
          n.date           :path => 'm:namePart[@type="date"]'

          n.alternative_name :path => 'm:alternativeName'
          n.displayForm :path => 'm:displayForm'
          n.affiliation :path => 'm:affiliation'
          n.description_el :path => 'm:description' # description is used by Nokogiri
          n.role :path => 'm:role' do |r|
            r.roleTerm :path => 'm:roleTerm' do |rt|
              with_attributes(rt, Mods::AUTHORITY_ATTRIBS | %w[type])
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

        t.personal_name    :path => '/m:mods/m:name[@type="personal"]'
        t._personal_name   :path => '//m:name[@type="personal"]'
        t.corporate_name   :path => '/m:mods/m:name[@type="corporate"]'
        t._corporate_name  :path => '//m:name[@type="corporate"]'
        t.conference_name  :path => '/m:mods/m:name[@type="conference"]'
        t._conference_name :path => '//m:name[@type="conference"]'

        # NOTE ---------------------------------------------------------------------------------
        t.note :path => '/m:mods/m:note'
        t._note :path => '//m:note' do |n|
          with_attributes(n, Mods::LANG_ATTRIBS | %w[ID displayLabel type])
        end

        # ORIGIN_INFO --------------------------------------------------------------------------
        t.origin_info :path => '/m:mods/m:originInfo'
        t._origin_info :path => '//m:originInfo' do |n|
          n.as_object :path => '.', :accessor => lambda { |a| Mods::OriginInfo.new(a) }
          # attributes
          with_attributes(n, Mods::LANG_ATTRIBS | %w[displayLabel])
          # child elements
          n.place :path => 'm:place' do |e|
            e.placeTerm :path => 'm:placeTerm' do |ee|
              with_attributes(ee, Mods::AUTHORITY_ATTRIBS | %w[type])
            end
          end
          n.publisher :path => 'm:publisher'
          Mods::OriginInfo::DATE_ELEMENTS.each { |date_el|
            n.send date_el, :path => "m:#{date_el}" do |d|
              d.as_object :path => '.', :accessor => lambda { |a| Mods::Date.from_element(a) }

              with_attributes(d, Mods::DATE_ATTRIBS)

              with_attributes(d, %w[type]) if date_el == 'dateOther'
            end
          }
          n.edition   :path => 'm:edition'
          n.issuance  :path => 'm:issuance'
          n.frequency :path => 'm:frequency' do |f|
            with_attributes(f, Mods::AUTHORITY_ATTRIBS)
          end
        end # t.origin_info

        # PART -----------------------------------------------------------------------------------
        t.part  :path => '/m:mods/m:part'
        t._part :path => '//m:part' do |n|
          # attributes
          with_attributes(n, Mods::LANG_ATTRIBS | %w[ID order type displayLabel])
          # child elements
          n.detail :path => 'm:detail' do |e|
            # attributes
            with_attributes(e, %w[level type])
            # elements
            e.number  :path => 'm:number'
            e.caption :path => 'm:caption'
            e.title   :path => 'm:title'
          end
          n.extent  :path => 'm:extent' do |e|  # TODO:  extent is ordered in xml schema
            # attributes
            with_attributes(e, %w[unit])
            # elements
            e.start :path => 'm:start'
            e.end   :path => 'm:end'
            e.total :path => 'm:total'
            e.list  :path => 'm:list'
          end
          n.date :path => 'm:date' do |e|
            with_attributes(e, Mods::DATE_ATTRIBS - ['keyDate'])
          end
          n.text_el :path => 'm:text' do |e|
            with_attributes(e, %w[displayLabel type])
          end
        end # t._part

        # PHYSICAL_DESCRIPTION -------------------------------------------------------------------
        t.physical_description  :path => '/m:mods/m:physicalDescription'
        t._physical_description :path => '//m:physicalDescription' do |n|
          # attributes
          with_attributes(n, Mods::LANG_ATTRIBS | %w[displayLabel])
          # child elements
          n.digitalOrigin :path => 'm:digitalOrigin'
          n.extent :path => 'm:extent'
          n.form :path => 'm:form' do |f|
            with_attributes(f, Mods::AUTHORITY_ATTRIBS | %w[type])
          end
          n.internetMediaType :path => 'm:internetMediaType'
          n.note :path => 'm:note' do |nn|
            with_attributes(nn,  %w[displayLabel type])
          end
          n.reformattingQuality :path => 'm:reformattingQuality'
        end

        # RECORD_INFO --------------------------------------------------------------------------
        t.record_info  :path => '/m:mods/m:recordInfo'
        t._record_info :path => '//m:recordInfo' do |n|
          # attributes
          with_attributes(n, Mods::LANG_ATTRIBS | %w[displayLabel])
          # child elements
          n.recordContentSource :path => 'm:recordContentSource' do |r|
            with_attributes(r, Mods::AUTHORITY_ATTRIBS)
          end
          n.recordCreationDate :path => 'm:recordCreationDate' do |r|
            with_attributes(r, Mods::DATE_ATTRIBS)
          end
          n.recordChangeDate :path => 'm:recordChangeDate' do |r|
            with_attributes(r, Mods::DATE_ATTRIBS)
          end
          n.recordIdentifier :path => 'm:recordIdentifier' do |r|
            with_attributes(r, ['source'])
          end
          n.recordOrigin :path => 'm:recordOrigin'
          n.languageOfCataloging :path => 'm:languageOfCataloging' do |r|
            with_attributes(r, Mods::AUTHORITY_ATTRIBS)
            r.languageTerm :path => 'm:languageTerm'
            r.scriptTerm :path => 'm:scriptTerm'
          end
          n.descriptionStandard :path => 'm:descriptionStandard' do |r|
            with_attributes(r, Mods::AUTHORITY_ATTRIBS)
          end
        end # t._record_info

        # RELATED_ITEM-------------------------------------------------------------------------
        t.related_item :path => '/m:mods/m:relatedItem' do |n|
          # attributes
          with_attributes(n, %w[ID displayLabel type])
          # elements
          n.abstract        :path => 'abstract'
          n.accessCondition :path => 'm:accessCondition'
          n.classification  :path => 'm:classification'
          n.extension       :path => 'm:extension'
          n.genre           :path => 'm:genre'
          n.identifier      :path => 'm:identifier'
          n.language        :path => 'm:language'
          n.location        :path => 'm:location'
          n.name_el         :path => 'm:name'  # Note:  'name' is used by Nokogiri
          n.personal_name   :path => 'm:name[@type="personal"]'
          n.corporate_name  :path => 'm:name[@type="corporate"]'
          n.conference_name :path => 'm:name[@type="conference"]'
          n.note            :path => 'm:note'
          n.originInfo      :path => 'm:originInfo'
          n.part            :path => 'm:part'
          n.physicalDescription :path => 'm:physicalDescription'
          n.recordInfo      :path => 'm:recordInfo'
          n.subject         :path => 'm:subject'
          n.tableOfContents :path => 'm:tableOfContents'
          n.targetAudience  :path => 'm:targetAudience'
          n.titleInfo       :path => 'm:titleInfo'
          n.typeOfResource  :path => 'm:typeOfResource'
        end

        # SUBJECT -----------------------------------------------------------------------------
        t.subject  :path => '/m:mods/m:subject'
        t._subject :path => '//m:subject' do |n|
          # attributes
          with_attributes(n, Mods::AUTHORITY_ATTRIBS | Mods::LANG_ATTRIBS | %w[displayLabel])
          # child elements
          n.cartographics  :path => 'm:cartographics' do |n1|
            n1.scale       :path => 'm:scale'
            n1.projection  :path => 'm:projection'
            n1.coordinates :path => 'm:coordinates'
            Mods::Subject::CARTOGRAPHICS_CHILD_ELEMENTS.each { |elname|
              n1.send elname, :path => "m:#{elname}"
            }
          end
          n.genre :path => 'm:genre' do |n1|
            with_attributes(n1, Mods::AUTHORITY_ATTRIBS)
          end
          n.geographic :path => 'm:geographic' do |n1|
            with_attributes(n1, Mods::AUTHORITY_ATTRIBS)
          end
          n.geographicCode :path => 'm:geographicCode' do |gc|
            with_attributes(gc, Mods::AUTHORITY_ATTRIBS)
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
            with_attributes(n1, Mods::AUTHORITY_ATTRIBS)
          end
          # Note:  'name' is used by Nokogiri
          n.name_el :path => 'm:name' do |t1|
            with_attributes(t1, Mods::AUTHORITY_ATTRIBS)
          end
          n.personal_name   :path => 'm:name[@type="personal"]'
          n.corporate_name  :path => 'm:name[@type="corporate"]'
          n.conference_name :path => 'm:name[@type="conference"]'
          n.occupation      :path => 'm:occupation' do |n1|
            with_attributes(n1, Mods::AUTHORITY_ATTRIBS)
          end
          n.temporal :path => 'm:temporal' do |n1|
            with_attributes(n1, Mods::AUTHORITY_ATTRIBS | Mods::DATE_ATTRIBS)
          end
          n.titleInfo :path => 'm:titleInfo' do |t1|
            with_attributes(t1, Mods::AUTHORITY_ATTRIBS)
          end
          n.topic :path => 'm:topic' do |n1|
            with_attributes(n1, Mods::AUTHORITY_ATTRIBS)
          end
        end # t.subject

        # TABLE_OF_CONTENTS ---------------------------------------------------------------------
        t.tableOfContents  :path => '/m:mods/m:tableOfContents'
        t._tableOfContents :path => '//m:tableOfContents' do |n|
          with_attributes(n, Mods::LANG_ATTRIBS | %w[displayLabel shareable type])
        end

        # TARGET_AUDIENCE -----------------------------------------------------------------------
        t.targetAudience  :path => '/m:mods/m:targetAudience'
        t._targetAudience :path => '//m:targetAudience' do |n|
          with_attributes(n, Mods::AUTHORITY_ATTRIBS | Mods::LANG_ATTRIBS | %w[displayLabel])
        end

        # TITLE_INFO ----------------------------------------------------------------------------
        t.title_info  :path => '/m:mods/m:titleInfo'
        t._title_info :path => '//m:titleInfo' do |n|
          with_attributes(n, Mods::TitleInfo::ATTRIBUTES)
          n.title      :path => 'm:title'
          n.subTitle   :path => 'm:subTitle'
          n.nonSort    :path => 'm:nonSort'
          n.partNumber :path => 'm:partNumber'
          n.partName   :path => 'm:partName'
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
        t.typeOfResource  :path => '/m:mods/m:typeOfResource'
        t._typeOfResource :path => '//m:typeOfResource' do |n|
          with_attributes(n, %w[collection displayLabel manuscript usage])
        end
      end

      mods_ng_xml.nom!
      mods_ng_xml
    end
  end
end
