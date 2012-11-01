module Mods
  class Reader

    attr_accessor :namespace_aware
    attr_reader :mods_ng_xml
    
    def initialize
      @namespace_aware = false
    end
    
    # @param str - a string containing mods xml
    # @return a Nokogiri::XML::Document object
    def from_str(str)
      @mods_ng_xml = Nokogiri::XML(str)
      normalize_mods
      @mods_ng_xml
    end
  
    # @param url - url that has mods xml as its content
    # @return a Nokogiri::XML::Document object
    def from_url(url, encoding = nil, options = Nokogiri::XML::ParseOptions::DEFAULT_XML)
      require 'open-uri'
      @mods_ng_xml = Nokogiri::XML(open(url).read)
      normalize_mods
      @mods_ng_xml
    end
    
    # Whatever we get, normalize it into a Nokogiri::XML::Document,
    # strip any elements enclosing the mods record
    def normalize_mods
      if !@namespace_aware
        @mods_ng_xml.remove_namespaces!
      end
    end
    
  end # class 
end # module