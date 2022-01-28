require 'edtf'

module Mods
  class Date
    attr_reader :xml

    ##
    # Ugly date factory that tries to pick an appropriate parser for the
    # type of data.
    #
    # @param [Nokogiri::XML::Element] xml A date-flavored MODS field from the XML
    # @return [Mods::Date]
    def self.from_element(xml)
      case xml.attr(:encoding)&.downcase
      when 'w3cdtf'
        Mods::Date::W3cdtfFormat.new(xml)
      when 'iso8601'
        Mods::Date::Iso8601Format.new(xml)
      when 'marc'
        Mods::Date::MarcFormat.new(xml)
      when 'edtf'
        Mods::Date::EdtfFormat.new(xml)
      # when 'temper'
      #   Mods::Date::TemperFormat.new(xml)
      else
        date_class = UnparseableDate if xml.text =~ /\p{Hebrew}/ || xml.text =~ /^-/
        date_class ||= [
          MMDDYYYYFormat,
          MMDDYYFormat,
          YearRangeFormat,
          DecadeAsYearDashFormat,
          EmbeddedBCYearFormat,
          EmbeddedYearFormat,
          EmbeddedThreeDigitYearFormat,
          EmbeddedYearWithBracketsFormat,
          MysteryCenturyFormat,
          CenturyFormat,
          RomanNumeralCenturyFormat,
          RomanNumeralYearFormat,
          OneOrTwoDigitYearFormat
        ].select { |klass| klass.supports? xml.text }.first

        (date_class || Mods::Date).new(xml)
      end
    rescue
      Mods::Date.new(xml)
    end

    # Strict ISO8601-encoded date parser
    class Iso8601Format < Date
      def self.parse_date(text)
        @date = ::Date.parse(normalize_to_edtf(text))
      end
    end

    # Less strict W3CDTF-encoded date parser
    class W3cdtfFormat < Date
    end

    # Strict EDTF parser
    class EdtfFormat < Date
      attr_reader :date

      def self.normalize_to_edtf(text)
        text
      end
    end

    # MARC-formatted date parser, similar to EDTF, but with special support for
    # MARC-specific encodings
    class MarcFormat < Date
      def self.normalize_to_edtf(text)
        return nil if text == "9999" || text == "uuuu" || text == '||||'

        super
      end

      private

      def earliest_date
        if xml.text == '1uuu'
          ::Date.parse('1000-01-01')
        else
          super
        end
      end

      def latest_date
        if xml.text == '1uuu'
          ::Date.parse('1999-12-31')
        else
          super
        end
      end
    end

    class ExtractorDateFormat < Date
      def self.supports?(text)
        text.match self::REGEX
      end
    end

    class UnparseableDate < ExtractorDateFormat
      def self.parse_date(text)
        nil
      end
    end

    # Full text extractor for MM/DD/YYYY and MM/DD/YYY-formatted dates
    class MMDDYYYYFormat < ExtractorDateFormat
      REGEX = /(?<month>\d{1,2})\/(?<day>\d{1,2})\/(?<year>\d{3,4})/

      def self.normalize_to_edtf(text)
        matches = text.match(self::REGEX)
        "#{matches[:year].rjust(4, "0")}-#{matches[:month].rjust(2, "0")}-#{matches[:day].rjust(2, "0")}"
      end
    end

    # Full text extractor for MM/DD/YY-formatted dates
    class MMDDYYFormat < ExtractorDateFormat
      REGEX = /(?<month>\d{1,2})\/(?<day>\d{1,2})\/(?<year>\d{2})/

      def self.normalize_to_edtf(text)
        matches = text.match(self::REGEX)
        year = munge_to_yyyy(matches[:year])
        "#{year}-#{matches[:month].rjust(2, "0")}-#{matches[:day].rjust(2, "0")}"
      end

      def self.munge_to_yyyy(text)
        if text.to_i > (::Date.current.year - 2000)
          "19#{text}"
        else
          "20#{text}"
        end
      end
    end

    # Full-text extractor for dates encoded as Roman numerals
    class RomanNumeralYearFormat < ExtractorDateFormat
      REGEX = /(?<![A-Za-z\.])(?<year>[MCDLXVI\.]+)(?![A-Za-z])/

      def self.normalize_to_edtf(text)
        matches = text.match(REGEX)
        roman_to_int(matches[:year].upcase).to_s
      end

      def self.roman_to_int(value)
        value = value.tr('.', '')
        map = { "M"=>1000, "CM"=>900, "D"=>500, "CD"=>400, "C"=>100, "XC"=>90, "L"=>50, "XL"=>40, "X"=>10, "IX"=>9, "V"=>5, "IV"=>4, "I"=>1 }
        result = 0
        map.each do |k,v|
          while value.index(k) == 0
            result += v
            value.slice! k
          end
        end
        result
      end
    end

    # Full-text extractor for centuries encoded as Roman numerals; sometimes centuries
    # are given as e.g. xvith, hence the funny negative look-ahead assertion
    class RomanNumeralCenturyFormat < RomanNumeralYearFormat
      REGEX = /(?<![a-z])(?<century>[xvi]+)(?![a-su-z])/

      def self.normalize_to_edtf(text)
        matches = text.match(REGEX)
        munge_to_yyyy(matches[:century])
      end

      def self.munge_to_yyyy(text)
        value = roman_to_int(text.upcase)
        (value - 1).to_s.rjust(2, "0") + 'XX'
      end
    end


    # Full-text extractor for a flavor of century encoding present in Stanford data
    # of unknown origin.
    class MysteryCenturyFormat < ExtractorDateFormat
      REGEX = /(?<century>\d{2})--/
      def self.normalize_to_edtf(text)
        matches = text.match(REGEX)
        "#{matches[:century]}XX"
      end
    end

    # Full-text extractor for dates given as centuries
    class CenturyFormat < ExtractorDateFormat
      REGEX = /(?<century>\d{2})th C(entury)?/i

      def self.normalize_to_edtf(text)
        matches = text.match(REGEX)
        "#{matches[:century].to_i - 1}XX"
      end
    end

    # Full-text extractor for data formatted as YYYY-YYYY or YYY-YYY
    class YearRangeFormat < ExtractorDateFormat
      REGEX = /(?<start>\d{3,4})-(?<end>\d{3,4})/

      def self.normalize_to_edtf(text)
        matches = text.match(REGEX)
        "#{matches[:start].rjust(4, "0")}/#{matches[:end].rjust(4, "0")}"
      end
    end

    # Full-text extractor for data formatted as YYY-
    class DecadeAsYearDashFormat < ExtractorDateFormat
      REGEX = /(?<!\d)(?<year>\d{3})[-_x?](?!\d)/

      def self.normalize_to_edtf(text)
        matches = text.match(REGEX)
        "#{matches[:year]}X"
      end
    end

    # Full-text extractor that tries hard to pick any year present in the data
    class EmbeddedBCYearFormat < ExtractorDateFormat
      REGEX = /(?<year>\d{3,4})\s?B\.?C\.?/i

      def self.normalize_to_edtf(text)
        matches = text.match(REGEX)
        "-#{(matches[:year].to_i - 1).to_s.rjust(4, "0")}"
      end
    end

    # Full-text extractor that tries hard to pick any year present in the data
    class EmbeddedYearFormat < ExtractorDateFormat
      REGEX = /(?<!\d)(?<year>\d{4})(?!\d)/

      def self.normalize_to_edtf(text)
        matches = text.match(REGEX)
        "#{matches[:year].rjust(4, "0")}"
      end
    end

    # Full-text extractor that tries hard to pick any year present in the data
    class EmbeddedThreeDigitYearFormat < ExtractorDateFormat
      REGEX = /(?<!\d)(?<year>\d{3})(?!\d)(?!\d)/

      def self.normalize_to_edtf(text)
        matches = text.match(REGEX)
        "#{matches[:year].rjust(4, "0")}"
      end
    end

    # Full-text extractor that tries hard to pick any year present in the data
    class OneOrTwoDigitYearFormat < ExtractorDateFormat
      REGEX = /^(?<year>\d{1,2})$/

      def self.normalize_to_edtf(text)
        matches = text.match(REGEX)
        "#{matches[:year].rjust(4, "0")}"
      end
    end

    # Full-text extractor that tries hard to pick any year present in the data
    class EmbeddedYearWithBracketsFormat < ExtractorDateFormat
      # [YYY]Y Y[YYY] [YY]YY Y[YY]Y YY[YY] YYY[Y] YY[Y]Y Y[Y]YY [Y]YYY
      REGEX = /(?<year>[\d\[\]]{6})(?!\d)/

      def self.normalize_to_edtf(text)
        matches = text.match(REGEX)
        "#{matches[:year].gsub('[', '').gsub(']', '')}"
      end
    end

    attr_reader :date

    ##
    # Parse a string to a Date or EDTF::Date using rules appropriate to the
    # given encoding
    # @param [String] text
    # @return [Date]
    def self.parse_date(text)
      return nil if text == '0000-00-00'
      ::Date.edtf(normalize_to_edtf(text))
    end

    ##
    # Apply any encoding-specific munging or text extraction logic
    # @param [String] text
    # @return [String]
    def self.normalize_to_edtf(text)
      sanitized = text.gsub(/^[\[]+/, '').gsub(/[\.\]]+$/, '')
      sanitized = text.rjust(4, "0") if text =~ /^\d{3}$/

      sanitized
    end

    def initialize(xml)
      @xml = xml
      @date = self.class.parse_date(xml.text.strip)
    end

    ##
    # Return a range, with the min point as the earliest possible date and
    # the max as the latest possible date (useful particularly for ranges and uncertainty)
    #
    # @param [Range]
    def as_range
      return unless earliest_date && latest_date

      earliest_date..latest_date
    end

    ##
    # Return an array of all years that fall into the range of possible dates
    # covered by the data. Note that some encodings support disjoint sets of ranges
    # so this method could provide more accuracy than #as_range (although potentially)
    # include a really big list of dates
    #
    # @return [Array]
    def to_a
      case date
      when EDTF::Set
        date.to_a
      else
        as_range.to_a
      end
    end

    ##
    # The text as encoded in the MODS
    # @return [String]
    def text
      xml.text
    end

    ##
    # The declared type of date (from the MODS @type attribute)
    #
    # @return [String]
    def type
      xml.attr(:type)&.downcase
    end

    ##
    # The declared encoding of date (from the MODS @encoding attribute)
    #
    # @return [String]
    def encoding
      xml.attr(:encoding)&.downcase
    end

    ##
    # Is the date marked as a keyDate?
    #
    # @return [Boolean]
    def key?
      xml.attr(:keyDate) == 'yes'
    end

    ##
    # Was an encoding provided?
    #
    # @return [Boolean]
    def encoding?
      !encoding.nil?
    end

    ##
    # The declared point of date (from the MODS @point attribute)
    #
    # @return [String]
    def point
      xml.attr(:point)&.downcase
    end

    ##
    # Is this date stand-alone, or part of a MODS-encoded range?
    #
    # @return [Boolean]
    def single?
      point.nil?
    end

    ##
    # Is this date the start of a MODS-encoded range?
    #
    # @return [Boolean]
    def start?
      point == 'start'
    end

    ##
    # Is this date the end point of a MODS-encoded range?
    #
    # @return [Boolean]
    def end?
      point == 'end'
    end

    ##
    # The declared qualifier of date (from the MODS @qualifier attribute)
    #
    # @return [String]
    def qualifier
      xml.attr(:qualifier)&.downcase
    end

    ##
    # Is the date declared as an approximate date?
    #
    # @return [Boolean]
    def approximate?
      qualifier == 'approximate'
    end

    ##
    # Is the date declared as an inferred date?
    #
    # @return [Boolean]
    def inferred?
      qualifier == 'inferred'
    end

    ##
    # Is the date declared as a questionable date?
    #
    # @return [Boolean]
    def questionable?
      qualifier == 'questionable'
    end

    def precision
      if date_range.is_a? EDTF::Century
        :century
      elsif date_range.is_a? EDTF::Decade
        :decade
      else
        case date.precision
        when :month
          date.unspecified.unspecified?(:month) ? :year : :month
        when :day
          d = date.unspecified.unspecified?(:day) ? :month : :day
          d = date.unspecified.unspecified?(:month) ? :year : d
          d
        else
          date.precision
        end
      end
    end

    private

    def days_in_month(month, year)
      if month == 2 && ::Date.gregorian_leap?(year)
        29
      else
        [nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][month]
      end
    end

    ##
    # Return the earliest possible date that is encoded in the data, respecting
    # unspecified or imprecise information.
    #
    # @return [::Date]
    def earliest_date
      return nil if date.nil?

      case date_range
      when EDTF::Unknown
        nil
      when EDTF::Epoch, EDTF::Interval
        date_range.min
      when EDTF::Set
        date_range.to_a.first
      else
        d = date.dup
        d = d.change(month: 1, day: 1) if date.precision == :year
        d = d.change(day: 1) if date.precision == :month
        d = d.change(month: 1) if date.unspecified.unspecified? :month
        d = d.change(day: 1) if date.unspecified.unspecified? :day
        d
      end
    end

    ##
    # Return the earliest possible date that is encoded in the data, respecting
    # unspecified or imprecise information.
    #
    # @return [::Date]
    def latest_date
      return nil if date.nil?

      case date_range
      when EDTF::Unknown
        nil
      when EDTF::Epoch, EDTF::Interval
        date_range.max
      when EDTF::Set
        date_range.to_a.last.change(month: 12, day: 31)
      else
        d = date.dup
        d = d.change(month: 12, day: 31) if date.precision == :year
        d = d.change(day: days_in_month(date.month, date.year)) if date.precision == :month
        d = d.change(month: 12) if date.unspecified.unspecified? :month
        d = d.change(day: days_in_month(date.month, date.year)) if date.unspecified.unspecified? :day
        d
      end
    end

    def date_range
      @date_range ||= if text =~ /u/
        ::Date.edtf(text.gsub('u', 'X')) || date
      else
        date
      end
    end
  end
end
