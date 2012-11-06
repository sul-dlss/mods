module Mods
  
  class Record
    
    # set the NOM terminology;  do NOT use namespaces
    # @param mods_ng_xml a Nokogiri::Xml::Document object containing MODS (without namespaces)
    def set_terminology_no_ns(mods_ng_xml)
      mods_ng_xml.set_terminology() do |t|

# FIXME: may want to deal with camelcase vs. underscore in method_missing          

        # note - titleInfo can be a top level element or a sub-element of relatedItem 
        #   (<titleInfo> as subelement of <subject> is not part of the MODS namespace)
        t.title_info :path => '/mods/titleInfo' do |n|
          n.title :path => 'title'
          n.subTitle :path => 'subTitle'
          n.nonSort :path => 'nonSort'
          n.partNumber :path => 'partNumber'
          n.partName :path => 'partName'
          n.type :path => '@type'
          n.sort_title :path => '.', :accessor => lambda { |node| 
            node.title.text + (!node.subTitle.text.empty? ? "#{@title_delimiter}#{node.subTitle.text}" : "" ) 
          }
          n.full_title :path => '.', :accessor => lambda { |node| 
             (!node.nonSort.text.empty? ? "#{node.nonSort.text} " : "" ) + 
             node.title.text + 
             (!node.subTitle.text.empty? ? "#{@title_delimiter}#{node.subTitle.text}" : "" ) 
          }
          n.short_title :path => '.', :accessor => lambda { |node|  
            if node.type.text != "alternative"
              (!node.nonSort.text.empty? ? "#{node.nonSort.text} " : "" ) + 
              node.title.text
            end
          }
          n.alternative_title :path => '.', :accessor => lambda { |node|  
            if node.type.text == "alternative"
              (!node.nonSort.text.empty? ? "#{node.nonSort.text} " : "" ) + 
              node.title.text
            end
          }
        end

        t.author :path => '/mods/name' do |n|
          n.valueURI :path => '@valueURI'
          n.namePart :path => 'namePart', :single => true
        end
#        t.author_names_as_array :path '/mods/name', :accessor => lambda {|node| }

        t.corporate_authors :path => '/mods/name[@type="corporate"]'
        t.personal_authors :path => '/mods/name[@type="personal"]' do |n|
          n.roleTerm :path => 'role/roleTerm'
          n.name_role_pair :path => '.', :accessor => lambda { |node| node.roleTerm.text + ": " + node.namePart.text }
          n.displayForm :path => 'displayForm'
          n.family_name :path => 'namePart[@type="family"]'
          n.given_name :path => 'namePart[@type="given"]'
          n.display_strings :path => '.', :accessor => lambda { |node| node.displayForm.nil? ? node.family_name + ', ' + node.given_name : node.displayName }
        end

        t.language :path => '/mods/language' do |n|
          n.value :path => 'languageTerm', :accessor => :text
        end

      end

      mods_ng_xml.nom!

      mods_ng_xml
    end # set_terminology_no_ns
    
    
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
          n.type :path => '@type'
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

