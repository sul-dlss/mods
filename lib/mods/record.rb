module Mods

  class Record

    attr_reader :mods_ng_xml

    NS_HASH = {'m' => MODS_NS_V3}

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

    # NAOMI_MUST_COMMENT_THIS_METHOD
    def name(*args, &proc)
      # we create a name object for each name, and then 
      #   do the method indicated
      #   put value in array return the value
# FIXME: this needs to cope with namespace aware, too
      names = @mods_ng_xml.xpath("/mods/name").map { |node| 
        n = Mods::Name.new(node)
        n.ng_node.element_children.size == 0 ? n.text.to_s : n
      }
    end

    # method for accessing simple top level elements
    def method_missing method_name, *args
      method_name_as_str = method_name.to_s
      if Mods::TOP_LEVEL_ELEMENTS.include?(method_name_as_str)
# FIXME: this needs to cope with namespace aware, too
        @mods_ng_xml.xpath("/mods/#{method_name_as_str}").map { |node| node.text  }
      else 
        super.method_missing(method_name, *args)
      end
    end
    
  end
end

class Array
  # if array elements are Mods::Name objects, then check Mods::Name for missing method
  def method_missing method_name, *args
    if !self.empty? && self.first.class == Mods::Name
      self.each_with_index { |name, i| 
        r = name.send(method_name, *args)
        self[i] = r.is_a?(Array) ? r.join(' ') : r
      }
    else
      super.method_missing(method_name, *args)
    end
  end

end
