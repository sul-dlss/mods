module Mods

  class Role

    attr_reader :ng_node, :text, :code, :authority

    # role nodes are currently parsed in a non-namespace aware manner.
    # @param (Nokogiri::XML::Node) role_node the MODS role node per the Mods::Record terminology
    def initialize(role_node)
      @ng_node = role_node
      if role_node.document.namespaces && role_node.document.namespaces.size > 0
        set_terminology_ns(Nokogiri::XML(role_node.to_s, nil, role_node.document.encoding))
      else
        set_terminology_no_ns(Nokogiri::XML(role_node.to_s, nil, role_node.document.encoding))
      end
      # note that there can be a roleTerm for text and a second one for code:
      # # from http://www.loc.gov/standards/mods/v3/mods-userguide-elements.html
      #  If both a code and a term are given that represent the same role, 
      #  use one <role> and multiple occurrences of <roleTerm>. If different roles, repeat <role><roleTerm>.
      @ng_node.roleTerm.each { |role_term|  
        @authority ||= @ng_node.roleTerm.authority
        if role_term.type_at == 'text'
          @text ||= role_term.text
        elsif role_term.type_at == 'code'
          @code ||= role_term.text
        end
      }
      @authority = nil if @authority == []  # missing data in terminology returns empty array
      if !@text && @code && @authority =~ /marcrelator/i
        @text = MARC_RELATOR[@code]
      end
    end
    
    # set the NOM terminology;  do NOT use namespaces
    # NOTES:
    # 1.  certain words, such as 'type' 'name' 'description' are reserved words in jruby or nokogiri
    #  when the terminology would use these words, a suffix of '_at' is added if it is an attribute, 
    #  (e.g. 'type_at' for @type) and a suffix of '_el' is added if it is an element.
    # @param role_ng_xml a Nokogiri::Xml::Document object containing MODS role Element(without namespaces)
    def set_terminology_no_ns(role_ng_xml)
      role_ng_xml.set_terminology() do |t|
        t.role :path => 'role' do |r| 
          r.roleTerm :path => 'roleTerm' do |rt|
            rt.type_at :path => "@type", :accessor => lambda { |a| a.text }
            Mods::AUTHORITY_ATTRIBS.each { |attr_name|
              rt.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
          end
        end
      end
      role_ng_xml.nom!
      role_ng_xml
    end

    # set the NOM terminology;  WITH namespaces
    # NOTES:
    # 1.  certain words, such as 'type' 'name' 'description' are reserved words in jruby or nokogiri
    #  when the terminology would use these words, a suffix of '_at' is added if it is an attribute, 
    #  (e.g. 'type_at' for @type) and a suffix of '_el' is added if it is an element.
    # @param role_ng_xml a Nokogiri::Xml::Document object containing MODS role Element(without namespaces)
    def set_terminology_ns(role_ng_xml)
      role_ng_xml.set_terminology(:namespaces => { 'm' => Mods::MODS_NS }) do |t|
        t.role :path => 'm:role' do |r| 
          r.roleTerm :path => 'm:roleTerm' do |rt|
            rt.type_at :path => "@type", :accessor => lambda { |a| a.text }
            Mods::AUTHORITY_ATTRIBS.each { |attr_name|
              rt.send attr_name, :path => "@#{attr_name}", :accessor => lambda { |a| a.text }
            }
          end
        end
      end
      role_ng_xml.nom!
      role_ng_xml
    end

  end
  
end