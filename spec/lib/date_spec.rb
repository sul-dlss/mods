require 'spec_helper'

RSpec.describe Mods::Date do
  subject(:date) { described_class.from_element(term) }
  let(:term) { Nokogiri::XML.fragment(date_element).first_element_child }

  describe '#to_a' do
    context 'with EDTF encoded sets' do
      let(:date_element) { "<dateCreated encoding=\"edtf\">[1667,1668,1670..1672]</dateCreated>" }

      it 'returns the list of years' do
        expect(date.to_a.map(&:year)).to match_array [1667, 1668, 1670, 1671, 1672]
      end
    end

    context 'with EDTF encoded ranges' do
      let(:date_element) { "<dateCreated encoding=\"edtf\">1856/1858</dateCreated>" }

      it 'returns the list of years' do
        expect(date.to_a.map(&:year)).to match_array [1856, 1857, 1858]
      end
    end

    context 'with random one-off years' do
      let(:date_element) { "<dateCreated>1856</dateCreated>" }

      it 'returns the year in an array' do
        expect(date.to_a.map(&:year)).to match_array [1856]
      end
    end
  end

  describe '#text' do
    let(:date_element) { "<dateCreated>1856</dateCreated>" }

    it 'returns the MODS text' do
      expect(date.text).to eq '1856'
    end
  end

  describe '#type' do
    let(:date_element) { "<dateCreated type='fictional'>1856</dateCreated>" }

    it 'returns the MODS type attribute' do
      expect(date.type).to eq 'fictional'
    end
  end

  describe '#encoding' do
    let(:date_element) { "<dateCreated encoding='fictional'>1856</dateCreated>" }

    it 'returns the MODS encoding attribute' do
      expect(date.encoding).to eq 'fictional'
    end
  end

  describe '#encoding?' do
    context 'with an encoding' do
      let(:date_element) { "<dateCreated encoding='fictional'>1856</dateCreated>" }

      it 'returns true' do
        expect(date.encoding?).to eq true
      end
    end

    context 'without an encoding' do
      let(:date_element) { "<dateCreated>1856</dateCreated>" }

      it 'returns false' do
        expect(date.encoding?).to eq false
      end
    end
  end

  describe '#key?' do
    context 'with keyDate=yes' do
      let(:date_element) { "<dateCreated keyDate='yes'>1856</dateCreated>" }

      it 'returns true' do
        expect(date.key?).to eq true
      end
    end

    context 'with a keyDate set to anything else' do
      let(:date_element) { "<dateCreated keyDate='fictional'>1856</dateCreated>" }

      it 'returns false' do
        expect(date.key?).to eq false
      end
    end
  end

  describe '#precision' do
    {
      '1905' => :year,
      '190u' => :decade,
      '19uu' => :century,
      '1900-uu' => :year,
      '1900-uu-uu' => :year,
      '1900-uu-15' => :year,
      '1900-06' => :month,
      '1900-06-uu' => :month,
      '1900-06-15' => :day,
      '2014-01-01/2020-12-31' => :day,
      '1986-22' => :month
    }.each do |data, expected|
      describe "with #{data}" do
        let(:date_element) { "<dateCreated encoding=\"edtf\">#{data}</dateCreated>" }

        it "has the range #{expected}" do
          expect(date.precision).to eq expected
        end
      end
    end
  end

  describe '#point' do
    let(:date_element) { "<dateCreated point='fictional'>1856</dateCreated>" }

    it 'returns the MODS point attribute' do
      expect(date.point).to eq 'fictional'
    end
  end

  describe '#single?' do
    context 'with a point' do
      let(:date_element) { "<dateCreated point='fictional'>1856</dateCreated>" }

      it 'returns false' do
        expect(date.single?).to eq false
      end
    end

    context 'without a point' do
      let(:date_element) { "<dateCreated>1856</dateCreated>" }

      it 'returns false' do
        expect(date.single?).to eq true
      end
    end
  end

  describe '#start?' do
    context 'with a point=start attribute' do
      let(:date_element) { "<dateCreated point='start'>1856</dateCreated>" }

      it 'returns true' do
        expect(date.start?).to eq true
      end
    end
  end

  describe '#end?' do
    context 'with a point=end attribute' do
      let(:date_element) { "<dateCreated point='end'>1856</dateCreated>" }

      it 'returns true' do
        expect(date.end?).to eq true
      end
    end
  end

  describe '#qualifier' do
    let(:date_element) { "<dateCreated qualifier='fictional'>1856</dateCreated>" }

    it 'returns the MODS qualifier attribute' do
      expect(date.qualifier).to eq 'fictional'
    end
  end

  describe '#approximate?' do
    context 'with a qualifier=approximate attribute' do
      let(:date_element) { "<dateCreated qualifier='approximate'>1856</dateCreated>" }

      it 'returns true' do
        expect(date.approximate?).to eq true
      end
    end
  end

  describe '#inferred?' do
    context 'with a qualifier=inferred attribute' do
      let(:date_element) { "<dateCreated qualifier='inferred'>1856</dateCreated>" }

      it 'returns true' do
        expect(date.inferred?).to eq true
      end
    end
  end

  describe '#questionable?' do
    context 'with a qualifier=questionable attribute' do
      let(:date_element) { "<dateCreated qualifier='questionable'>1856</dateCreated>" }

      it 'returns true' do
        expect(date.questionable?).to eq true
      end
    end
  end

  describe 'EDTF encoded dates' do
    {
      '1905' => Date.parse('1905-01-01')..Date.parse('1905-12-31'),
      '190u' => Date.parse('1900-01-01')..Date.parse('1909-12-31'),
      '190x' => Date.parse('1900-01-01')..Date.parse('1909-12-31'),
      '19uu' => Date.parse('1900-01-01')..Date.parse('1999-12-31'),
      '19xx' => Date.parse('1900-01-01')..Date.parse('1999-12-31'),
      '1856/1876' => Date.parse('1856-01-01')..Date.parse('1876-12-31'),
      '[1667,1668,1670..1672]' => Date.parse('1667-01-01')..Date.parse('1672-12-31'),
      '1900-uu' => Date.parse('1900-01-01')..Date.parse('1900-12-31'),
      '1900-uu-uu' => Date.parse('1900-01-01')..Date.parse('1900-12-31'),
      '1900-uu-15' => Date.parse('1900-01-15')..Date.parse('1900-12-15'),
      '1900-06-uu' => Date.parse('1900-06-01')..Date.parse('1900-06-30'),
      '-250' => Date.parse('-250-01-01')..Date.parse('-250-12-31'), # EDTF requires a 4 digit year, but what can you do.
      '63' => Date.parse('0063-01-01')..Date.parse('0063-12-31'),
      '125' => Date.parse('125-01-01')..Date.parse('125-12-31'),
    }.each do |data, expected|
      describe "with #{data}" do
        let(:date_element) { "<dateCreated encoding=\"edtf\">#{data}</dateCreated>" }

        it "has the range #{expected}" do
          expect(date).to be_single
          expect(date.encoding).to eq 'edtf'
          expect(date.as_range.to_s).to eq expected.to_s
        end
      end
    end
  end

  describe 'W3cdtf encoded dates' do
    {
      '1753' => Date.parse('1753-01-01')..Date.parse('1753-12-31'),
      '-1753' => Date.parse('-1753-01-01')..Date.parse('-1753-12-31'),
      '1992-00-00' => Date.parse('1992-01-01')..Date.parse('1992-12-31'),
      '1992-05-06' => Date.parse('1992-05-06')..Date.parse('1992-05-06'),
      '1992-04' => Date.parse('1992-04-01')..Date.parse('1992-04-30'),
      '2004-02' => Date.parse('2004-02-01')..Date.parse('2004-02-29'),
      '123' => Date.parse('123-01-01')..Date.parse('123-12-31') # not technically valid, but we have lots of these
    }.each do |data, expected|
      describe "with #{data}" do
        let(:date_element) { "<dateCreated encoding=\"w3cdtf\">#{data}</dateCreated>" }

        it "has the range #{expected}" do
          expect(date).to be_single
          expect(date.encoding).to eq 'w3cdtf'
          expect(date.as_range.to_s).to eq expected.to_s
        end
      end
    end
  end

  describe 'MARC encoded dates' do
    {
      '1234' => Date.parse('1234-01-01')..Date.parse('1234-12-31'),
      '9999' => nil,
      '1uuu' => Date.parse('1000-01-01')..Date.parse('1999-12-31'),
      '||||' => nil
    }.each do |data, expected|
      describe "with #{data}" do
        let(:date_element) { "<dateCreated encoding=\"marc\">#{data}</dateCreated>" }

        it "has the range #{expected}" do
          expect(date).to be_single
          expect(date.encoding).to eq 'marc'
          expect(date.as_range.to_s).to eq expected.to_s
        end
      end
    end
  end

  describe 'ISO8601 encoded dates' do
    {
      '20131114161429' => Date.parse('20131114161429')..Date.parse('20131114161429')
    }.each do |data, expected|
      describe "with #{data}" do
        let(:date_element) { "<dateCreated encoding=\"iso8601\">#{data}</dateCreated>" }

        it "has the range #{expected}" do
          expect(date).to be_single
          expect(date.encoding).to eq 'iso8601'
          expect(date.as_range.to_s).to eq expected.to_s
        end
      end
    end
  end

  describe 'MDY encoded dates' do
    {
      '11/27/2017' => Date.parse('2017-11-27')..Date.parse('2017-11-27'),
      '5/27/2017' => Date.parse('2017-05-27')..Date.parse('2017-05-27'),
      '5/2/2017' => Date.parse('2017-05-02')..Date.parse('2017-05-02'),
      '12/1/2017' => Date.parse('2017-12-01')..Date.parse('2017-12-01'),
      '12/1/17' => Date.parse('2017-12-01')..Date.parse('2017-12-01'),
      '12/1/25' => Date.parse('1925-12-01')..Date.parse('1925-12-01'),
      '6/18/938' => Date.parse('0938-06-18')..Date.parse('0938-06-18')
    }.each do |data, expected|
      describe "with #{data}" do
        let(:date_element) { "<dateCreated>#{data}</dateCreated>" }

        it "has the range #{expected}" do
          expect(date).to be_single
          expect(date.as_range.to_s).to eq expected.to_s
        end
      end
    end
  end

  describe 'Pulling out 4-digit years from unspecified dates' do
    {
      'Minguo 19 [1930]' => Date.parse('1930-01-01')..Date.parse('1930-12-31'),
      '1745 mag. 14' => Date.parse('1745-01-01')..Date.parse('1745-12-31'),
      '-745' => '', # too ambiguious to even attempt.
      '-1999' => '', # too ambiguious to even attempt.
      '[1923]' => Date.parse('1923-01-01')..Date.parse('1923-12-31'),
      '1532.' => Date.parse('1532-01-01')..Date.parse('1532-12-31'),
      '[ca 1834]' => Date.parse('1834-01-01')..Date.parse('1834-12-31'),
      'xvi' => Date.parse('1500-01-01')..Date.parse('1599-12-31'),
      'cent. xvi' => Date.parse('1500-01-01')..Date.parse('1599-12-31'),
      'MDLXXVIII' => Date.parse('1578-01-01')..Date.parse('1578-12-31'),
      '[19--?]-' => Date.parse('1900-01-01')..Date.parse('1999-12-31'),
      '19th Century' => Date.parse('1800-01-01')..Date.parse('1899-12-31'),
      '19th c.' => Date.parse('1800-01-01')..Date.parse('1899-12-31'),
      'mid to 2nd half of 13th century' => Date.parse('1200-01-01')..Date.parse('1299-12-31'),
      '167-?]' => Date.parse('1670-01-01')..Date.parse('1679-12-31'),
      '189-?' => Date.parse('1890-01-01')..Date.parse('1899-12-31'),
      '193-' => Date.parse('1930-01-01')..Date.parse('1939-12-31'),
      '196_' => Date.parse('1960-01-01')..Date.parse('1969-12-31'),
      '196x' => Date.parse('1960-01-01')..Date.parse('1969-12-31'),
      '196u' => Date.parse('1960-01-01')..Date.parse('1969-12-31'),
      '1960s' => Date.parse('1960-01-01')..Date.parse('1969-12-31'),
      '186?' => Date.parse('1860-01-01')..Date.parse('1869-12-31'),
      '1700?' => Date.parse('1700-01-01')..Date.parse('1700-12-31'),
      'early 1730s' => Date.parse('1730-01-01')..Date.parse('1739-12-31'),
      '[1670-1684]' => Date.parse('1670-01-01')..Date.parse('1684-12-31'),
      '[18]74' => Date.parse('1874-01-01')..Date.parse('1874-12-31'),
      '250 B.C.' => Date.parse('-0249-01-01')..Date.parse('-249-12-31'),
      'Anno M.DC.LXXXI.' => Date.parse('1681-01-01')..Date.parse('1681-12-31'),
      '624[1863 or 1864]' => Date.parse('1863-01-01')..Date.parse('1863-12-31'),
      'chez Villeneuve' => nil,
      '‏4264681 או 368' => nil
    }.each do |data, expected|
      describe "with #{data}" do
        let(:date_element) { "<dateCreated>#{data}</dateCreated>" }

        it "has the range #{expected}" do
          expect(date).to be_single
          expect(date.as_range.to_s).to eq expected.to_s
        end
      end
    end
  end

  describe 'garbage data' do
    let(:date_element) { "<dateCreated>n.d.</dateCreated>" }

    it 'handles it gracefully' do
      expect(date.as_range).to be_nil
      expect(date.to_a).to be_empty
      expect(date.text).to eq 'n.d.'
    end

    context 'for dates with encodings declared, but invalid data' do
      let(:date_element) { "<dateCreated encoding='iso8601'>n.d.</dateCreated>" }

      it 'handles it gracefully' do
        expect(date.as_range).to be_nil
        expect(date.to_a).to be_empty
        expect(date.text).to eq 'n.d.'
      end
    end
  end
end
