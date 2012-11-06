module Mods
  
  class Record
    
    # set the NOM terminology;  do NOT use namespaces
    # @param mods_ng_xml a Nokogiri::Xml::Document object containing MODS (without namespaces)
    def set_terminology_no_ns(mods_ng_xml)
      mods_ng_xml.set_terminology() do |t|

# FIXME: may want to deal with camelcase vs. underscore in method_missing 
 
        # These elements have no subelements - w00t!
        Mods::TOP_LEVEL_ELEMENTS_SIMPLE.each { |elname|
          t.send elname, :path => "/mods/#{elname}", :accessor => lambda { |n| n.text }
        }

        # note - titleInfo can be a top level element or a sub-element of relatedItem 
        #   (<titleInfo> as subelement of <subject> is not part of the MODS namespace)
        t.title_info :path => '/mods/titleInfo' do |n|
          n.type :path => '@type'
          n.title :path => 'title'
          n.subTitle :path => 'subTitle'
          n.nonSort :path => 'nonSort'
          n.partNumber :path => 'partNumber'
          n.partName :path => 'partName'
          n.sort_title :path => '.', :accessor => lambda { |node| 
            if node.type.text != "alternative" || (node.type.text == "alternative" && mods_ng_xml.xpath('/mods/titleInfo').size == 1)
              node.title.text + (!node.subTitle.text.empty? ? "#{@title_delimiter}#{node.subTitle.text}" : "" ) 
            end
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

        # current way to do short_title correctly
#        t.short_title :path => '/mods/titleInfo[not(@type=alternative)]', :accessor => lambda { |node|  
#            (!node.nonSort.text.empty? ? "#{node.nonSort.text} " : "" ) + 
#            node.title.text
#          }

=begin
        t.name :path => '/mods/name' do |n|
          n.type :path => '@type'
          n.authority :path => '@authority'
          n.namePart :path => 'namePart' do |np|
            np.type :path => '@type'
          end
          n.displayForm :path => 'dislayForm'
          n.affiliation :path => 'affiliation'
          n.description :path => 'description'
          n.role :path => 'role' do |r|
            r.roleTerm :path => "roleTerm" do |rt|
              rt.type :path => "@type"
              rt.authority :path => "@authority"
            end
          end
#          n.personal :path => '.', :accessor => lambda { |node| node.text }
#          n.display_string :path => '.', :accessor => lambda { |node| node.displayForm.nil? ? node.family_name + ', ' + node.given_name : node.displayForm }
        end
=end        
        t.personal_name :path => '/mods/name[@type="personal"]' do |n|
          n.namePart :path => 'namePart'
          n.family_name :path => 'namePart[@type="family"]'
          n.given_name :path => 'namePart[@type="given"]'
          n.termsOfAddress :path => 'namePart[@type="termsOfAddress"]'
          n.date :path => 'namePart[@type="date"]'
          n.displayForm :path => 'displayForm'
          n.affiliation :path => 'affiliation'
          n.description :path => 'description'
# FIXME:  this should work - it's a NOM bug          
#          n.role :path => 'role/roleTerm' do |r|
#            r.type :path => "@type"
#            r.authority :path => "@authority"
#          end
          n.role :path => 'role' do |r|
            r.roleTerm :path => "roleTerm" do |rt|
              rt.type :path => "@type"
              rt.authority :path => "@authority"
            end
          end
        end
        t.corporate_name :path => '/mods/name[@type="corporate"]' do |n|
          n.namePart :path => 'namePart'
          n.roleTerm :path => 'role/roleTerm[@type="text"]'
        end
=begin        
        t.conference_name :path => '/mods/name[@type="conference"]'


        t.language :path => '/mods/language' do |n|
          n.value :path => 'languageTerm', :accessor => :text
        end
=end
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

