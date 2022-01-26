# frozen_string_literal: true

module Fixtures
  def mods_record(xml)
    Mods::Record.new.from_str(<<-XML)
      <mods xmlns='#{Mods::MODS_NS}'>
        #{xml}
      </mods>
    XML
  end
end
