module Mods

  class Record

    attr_reader :mods_ng_xml
    # string to use when combining a title and subtitle, e.g. 
    #  for title "MODS" and subtitle "Metadata Odious Delimited Stuff" and delimiter " : "
    #  we get "MODS : Metadata Odious Delimited Stuff"
    attr_accessor :title_delimiter

    NS_HASH = {'m' => MODS_NS_V3}
    
    ATTRIBUTES = ['id', 'version']

    # @param (String) what to use when combining a title and subtitle, e.g. 
    #  for title "MODS" and subtitle "Metadata Odious Delimited Stuff" and delimiter " : "
    #  we get "MODS : Metadata Odious Delimited Stuff"
    def initialize(title_delimiter = Mods::TitleInfo::DEFAULT_TITLE_DELIM)
      @title_delimiter = title_delimiter
    end

    # convenience method to call Mods::Reader.new.from_str and to nom
    # @param ns_aware true if the XML parsing should be strict about using namespaces.  Default is false
    # @param str - a string containing mods xml
    def from_str(str, ns_aware = false)
      @mods_ng_xml = Mods::Reader.new(ns_aware).from_str(str)
      if ns_aware
        set_terminology_ns(@mods_ng_xml)
      else
        set_terminology_no_ns(@mods_ng_xml)
      end
    end

    # convenience method to call Mods::Reader.new.from_url and to nom
    # @param ns_aware true if the XML parsing should be strict about using namespaces.  Default is false
    # @param url (String) - url that has mods xml as its content
    def from_url(url, namespace_aware = false)
      @mods_ng_xml = Mods::Reader.new(ns_aware).from_url(url)
      if ns_aware
        set_terminology_ns(@mods_ng_xml)
      else
        set_terminology_no_ns(@mods_ng_xml)
      end
    end

    # @return Array of Strings, each containing the text contents of <mods><titleInfo>   <nonSort> + ' ' + <title> elements
    #  but not including any titleInfo elements with type="alternative"
    def short_titles
      @mods_ng_xml.title_info.short_title.reject { |n| n.nil? }
    end

    # @return Array of Strings, each containing the text contents of <mods><titleInfo>   <nonSort> + ' ' + <title> + (delim) + <subTitle> elements
    def full_titles
      @mods_ng_xml.title_info.full_title.reject { |n| n.nil? }
    end
        
    # @return Array of Strings, each containing the text contents of <mods><titleInfo @type="alternative"><title>  elements
    def alternative_titles
      @mods_ng_xml.title_info.alternative_title.reject { |n| n.nil? }
    end
    
    # @return String containing sortable title for this mods record
    def sort_title
      @mods_ng_xml.title_info.sort_title.find { |n| !n.nil? }
    end
    
    
    # use the displayForm of a personal name if present
    #   if no displayForm, try to make a string from family name and given name "family_name, given_name"
    #   otherwise, return all nameParts concatenated together
    # @return Array of Strings, each containing ...
    def personal_names
      @mods_ng_xml.personal_name.map { |n|
        if n.displayForm.size > 0
          n.displayForm.text
        elsif n.family_name.size > 0
          n.given_name.size > 0 ? n.family_name.text + ', ' + n.given_name.text : n.family_name.text
        else
          n.namePart.text
        end
      }
    end

    # @return Array of Strings, each containing ...
    def corporate_names
      @mods_ng_xml.corporate_name.map { |n| n.text }
    end


=begin    
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
=end

    # method for accessing simple top level elements
    def method_missing method_name, *args
      if mods_ng_xml.respond_to?(method_name)
        mods_ng_xml.send(method_name, *args)
      else
=begin
        method_name_as_str = method_name.to_s
        if ATTRIBUTES.include?(method_name_as_str)
          @mods_ng_xml.xpath("/mods/@#{method_name_as_str}").text.to_s
        elsif Mods::TOP_LEVEL_ELEMENTS.include?(method_name_as_str)
  # FIXME: this needs to cope with namespace aware, too
          @mods_ng_xml.xpath("/mods/#{method_name_as_str}").map { |node| node.text  }
        else 
          super.method_missing(method_name, *args)
        end
=end      
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
