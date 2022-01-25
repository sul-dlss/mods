require 'iso-639'

module Mods

  class Record

    attr_reader :mods_ng_xml
    # string to use when combining a title and subtitle, e.g.
    #  for title "MODS" and subtitle "Metadata Odious Delimited Stuff" and delimiter " : "
    #  we get "MODS : Metadata Odious Delimited Stuff"
    attr_accessor :title_delimiter

    NS_HASH = {'m' => MODS_NS_V3}

    ATTRIBUTES = ['id', 'version']

    # @param (String) title_delimiter what to use when combining a title and subtitle, e.g.
    #  for title "MODS" and subtitle "Metadata Odious Delimited Stuff" and delimiter " : "
    #  we get "MODS : Metadata Odious Delimited Stuff"
    def initialize(title_delimiter = Mods::TitleInfo::DEFAULT_TITLE_DELIM)
      @title_delimiter = title_delimiter
    end

    # convenience method to call Mods::Reader.new.from_str and to nom
    # @param ns_aware true if the XML parsing should be strict about using namespaces.  Default is true
    # @param str - a string containing mods xml
    # @return Mods::Record
    def from_str(str)
      @mods_ng_xml = Mods::Reader.new.from_str(str)
      set_terminology_ns(@mods_ng_xml)

      return self
    end

    # Convenience method to call Mods::Reader.new.from_url and to nom.
    # Returns a new instance of Mods::Record instantiated with the content from the given URL.
    # @param url (String) - url that has mods xml as its content
    # @param namespace_aware true if the XML parsing should be strict about using namespaces.  Default is true
    # @return Mods::Record
    # @example
    #   foo = Mods::Record.new.from_url('http://purl.stanford.edu/bb340tm8592.mods')
    def from_url(url)
      @mods_ng_xml = Mods::Reader.new.from_url(url)
      set_terminology_ns(@mods_ng_xml)
      return self
    end

    # Convenience method to call Mods::Reader.new.from_file.
    # Returns a new instance of Mods::Record instantiated with the content from the given file.
    # @param file (String) - path to file that has mods xml as its content
    # @param namespace_aware true if the XML parsing should be strict about using namespaces.  Default is true
    # @return Mods::Record
    # @example
    #   foo = Mods::Record.new.from_file('/path/to/file/bb340tm8592.mods')
    def from_file(url)
      @mods_ng_xml = Mods::Reader.new.from_file(url)
      set_terminology_ns(@mods_ng_xml)
      return self
    end

    # convenience method to call Mods::Reader.new.from_nk_node and to nom
    # @param node (Nokogiri::XML::Node) - Nokogiri::XML::Node that is the top level element of a mods record
    # @param ns_aware true if the XML parsing should be strict about using namespaces.  Default is true
    # @return Mods::Record
    def from_nk_node(node)
      @mods_ng_xml = Mods::Reader.new.from_nk_node(node)
      set_terminology_ns(@mods_ng_xml)
      return self
    end

    # get the value for the terms, as a String. f there are multiple values, they will be joined with the separator.
    #  If there are no values, the result will be nil.
    # @param [Symbol or String or Array<Symbol>] messages the single symbol of the message to send to the Stanford::Mods::Record object
    #  (as a Symbol or a String), or an Array of (Symbols or Strings) to be sent as messages.
    #  Messages will usually be terms from the nom-xml terminology defined in the mods gem.)
    # @param [String] sep - the separator string to insert between multiple values
    # @return [String] a String representing the value(s) or nil.
    def term_value messages, sep = ' '
      vals = term_values messages
      return nil if !vals
      val = vals.join sep
    end

    # get the values for the terms, as an Array. If there are no values, the result will be nil.
    # @param [Symbol or String or Array<Symbol>] messages the single symbol of the message to send to the Stanford::Mods::Record object
    #  (as a Symbol or a String), or an Array of (Symbols or Strings) to be sent as messages.
    #  Messages will usually be terms from the nom-xml terminology defined in the mods gem.)
    # @return [Array<String>] an Array with a String value for each result node's non-empty text, or nil if none
    def term_values messages
      case messages
        when Symbol
          nodes = send(messages)
        when String
          nodes = send(messages.to_sym)
        when Array
          obj = self
          messages.each { |msg|
            if msg.is_a? Symbol
              obj = obj.send(msg)
            elsif msg.is_a? String
              obj = obj.send(msg.to_sym)
            else
              raise ArgumentError, "term_values called with Array containing unrecognized class: #{msg.class}, #{messages.inspect}", caller
            end
          }
          nodes = obj
        else
          raise ArgumentError, "term_values called with unrecognized argument class: #{messages.class}", caller
      end

      vals = []
      if nodes
        nodes.each { |n|
          vals << n.text unless n.text.empty?
        }
      end
      return nil if vals.empty?
      vals
    rescue NoMethodError
      raise ArgumentError, "term_values called with unknown argument: #{messages.inspect}", caller
    end


    # @return Array of Strings, each containing the text contents of <mods><titleInfo>   <nonSort> + ' ' + <title> elements
    #  but not including any titleInfo elements with type="alternative"
    def short_titles
      @mods_ng_xml.title_info.short_title.map { |n| n }
    end

    # @return Array of Strings, each containing the text contents of <mods><titleInfo>   <nonSort> + ' ' + <title> + (delim) + <subTitle> elements
    def full_titles
      @mods_ng_xml.title_info.full_title.map { |n| n }
    end

    # @return Array of Strings, each containing the text contents of <mods><titleInfo @type="alternative"><title>  elements
    def alternative_titles
      @mods_ng_xml.title_info.alternative_title.map { |n| n }
    end

    # @return String containing sortable title for this mods record
    def sort_title
      @mods_ng_xml.title_info.sort_title.find { |n| !n.nil? }
    end

    # @return Array of Strings, each containing the computed display value of a personal name
    #   (see nom_terminology for algorithm)
    def personal_names
      @mods_ng_xml.personal_name.map { |n| n.display_value }
    end

    # @return Array of Strings, each containing the computed display value of a personal name
    #   (see nom_terminology for algorithm)
    def personal_names_w_dates
      @mods_ng_xml.personal_name.map { |n| n.display_value_w_date }
    end

    # use the displayForm of a corporate name if present
    #   otherwise, return all nameParts concatenated together
    # @return Array of Strings, each containing the above described string
    def corporate_names
      @mods_ng_xml.corporate_name.map { |n| n.display_value }
    end

    # Translates iso-639 language codes, and leaves everything else alone.
    # @return Array of Strings, each a (hopefully English) name of a language
    def languages
      result = []
      @mods_ng_xml.language.each { |n|
        # get languageTerm codes and add their translations to the result
        n.code_term.each { |ct|
          if ct.authority.match(/^iso639/)
            begin
              vals = ct.text.split(/[,|\ ]/).reject {|x| x.strip.length == 0 }
              vals.each do |v|
                result << ISO_639.find(v.strip).english_name
              end
            rescue => e
              p "Couldn't find english name for #{ct.text}"
              result << ct.text
            end
          else
            result << ct.text
          end
        }
        # add languageTerm text values
        n.text_term.each { |tt|
          val = tt.text.strip
          result << val if val.length > 0
        }

        # add language values that aren't in languageTerm subelement
        if n.languageTerm.size == 0
          result << n.text
        end
      }
      result.uniq
    end

    def method_missing method_name, *args
      if mods_ng_xml.respond_to?(method_name)
        mods_ng_xml.send(method_name, *args)
      else
        super.method_missing(method_name, *args)
      end
    end

  end # class Record

end # module Mods
