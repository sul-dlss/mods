# encoding: UTF-8

module Mods
  class Reader
    # @param ns_aware true if the XML parsing should be strict about using namespaces.  Default is true
    def initialize
    end

    # @param str - a string containing mods xml
    # @return Nokogiri::XML::Document
    def from_str(str)
      Nokogiri::XML(str, nil, str.encoding.to_s)
    end

    # Read in the contents of a Mods file from a url.
    # @param url (String) - url that has mods xml as its content
    # @return Nokogiri::XML::Document
    # @example
    #   foo = Mods::Reader.new.from_url('http://purl.stanford.edu/bb340tm8592.mods')
    def from_url(url, encoding = nil, options = Nokogiri::XML::ParseOptions::DEFAULT_XML)
      require 'open-uri'
      Nokogiri::XML(URI.open(url).read)
    end

    # Read in the contents of a Mods record from a file.
    # @param filename (String) - path to file that has mods xml as its content
    # @return Nokogiri::XML::Document
    # @example
    #   foo = Mods::Reader.new.from_file('/path/to/mods/file.xml')
    def from_file(filename, encoding = nil, options = Nokogiri::XML::ParseOptions::DEFAULT_XML)
      File.open(filename) do |file|
        Nokogiri::XML(file)
      end
    end

    # @param node (Nokogiri::XML::Node) - Nokogiri::XML::Node that is the top level element of a mods record
    # @return Nokogiri::XML::Document
    def from_nk_node(node)
      Nokogiri::XML(node.to_s, nil, node.document.encoding)
    end
  end
end
