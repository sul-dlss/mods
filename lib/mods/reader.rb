module Mods
  class Reader
    
    DEFAULT_NS_AWARE = false

    # true if the XML parsing should be strict about using namespaces. 
    attr_accessor :namespace_aware
    attr_reader :mods_ng_xml
    
    # @param ns_aware true if the XML parsing should be strict about using namespaces.  Default is false
    def initialize(ns_aware = DEFAULT_NS_AWARE)
      @namespace_aware = ns_aware
    end
    
    # @param str - a string containing mods xml
    # @return a Nokogiri::XML::Document object
    def from_str(str)
      @mods_ng_xml = Nokogiri::XML(str)
      normalize_mods
      @mods_ng_xml
    end
  
    # @param url (String) - url that has mods xml as its content
    # @return a Nokogiri::XML::Document object
    def from_url(url, encoding = nil, options = Nokogiri::XML::ParseOptions::DEFAULT_XML)
      require 'open-uri'
      @mods_ng_xml = Nokogiri::XML(open(url).read)
      normalize_mods
      @mods_ng_xml
    end
    
    # @param node (Nokogiri::XML::Node) - Nokogiri::XML::Node that is the top level element of a mods record
    # @return a Nokogiri::XML::Document object
    def from_nk_node(node)
      @mods_ng_xml = Nokogiri::XML(node.to_s)
      normalize_mods
      @mods_ng_xml
    end
    
    # Whatever we get, normalize it into a Nokogiri::XML::Document,
    # strip any elements enclosing the mods record
    def normalize_mods
      if !@namespace_aware
        @mods_ng_xml.remove_namespaces!
        # xsi:schemaLocation attribute will cause problems in JRuby
        if @mods_ng_xml.root && @mods_ng_xml.root.attributes.keys.include?('schemaLocation')
          @mods_ng_xml.root.remove_attribute('schemaLocation')
        end
        # doing weird re-reading of xml for jruby, which gets confused by its own cache
        @mods_ng_xml = Nokogiri::XML(@mods_ng_xml.to_s)
      end
    end
    
  end # class 
end # module