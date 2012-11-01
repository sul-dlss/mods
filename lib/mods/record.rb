# NAOMI_MUST_COMMENT_THIS_MODULE
module Mods
  # NAOMI_MUST_COMMENT_THIS_CLASS
  class Record

    attr_reader :mods_ng_xml

    def initialize
    end

    # convenience method to call Mods::Reader.new.from_str
    # @param ns_aware true if the XML parsing should be strict about using namespaces.  Default is false
    # @param str - a string containing mods xml
    def from_str(str, ns_aware = false)
      @mods_ng_xml = Mods::Reader.new(ns_aware).from_str(str)
    end

    # convenience method to call Mods::Reader.new.from_url
    # @param ns_aware true if the XML parsing should be strict about using namespaces.  Default is false
    # @param url (String) - url that has mods xml as its content
    def from_url(url, namespace_aware = false)
      @mods_ng_xml = Mods::Reader.new(ns_aware).from_url(url)
    end

    # method for accessing simple top level elements
    # NAOMI_MUST_COMMENT_THIS_METHOD
    def method_missing method_name, *args
      method_name_as_str = method_name.to_s
      if Mods::TOP_LEVEL_ELEMENTS_SIMPLE.include?(method_name_as_str)
        @mods_ng_xml.xpath("/mods/#{method_name_as_str}").map { |node| node.text  }
      else
        super.method_missing(method_name, args)
      end
    end
    
    
    
  end
end