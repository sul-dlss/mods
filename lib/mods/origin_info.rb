# frozen_string_literal: true

module Mods
  class OriginInfo
    DATE_ELEMENTS = %w[dateIssued dateCreated dateCaptured dateValid dateModified copyrightDate
                       dateOther].freeze

    attr_reader :xml

    def initialize(xml)
      @xml = xml
    end

    def dates
      DATE_ELEMENTS.flat_map { |element| xml.public_send(element) }
    end

    def key_dates
      d = dates.select { |x| x.keyDate == 'yes' }

      d += dates.select { |x| x.point == 'end' && d.any? { |date| date.name == x.name && date.point == 'start' } }
    end
  end
end
