module Mods
  class OriginInfo
    DATE_ELEMENTS = ['dateIssued', 'dateCreated', 'dateCaptured', 'dateValid', 'dateModified', 'copyrightDate', 'dateOther']

    attr_reader :xml

    def initialize(xml)
      @xml = xml
    end

    def dates
      DATE_ELEMENTS.flat_map { |element| xml.public_send(element) }
    end

    def key_dates
      dates.select { |x| x.keyDate == 'yes' }
    end
  end
end
