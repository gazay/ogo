module Ogo
  class PageSource

    attr_reader :url, :src, :charset, :doc

    def initialize(src, options={})
      @src = src
      @url = options[:url]
      @charset = options[:charset]
    end

    def parse
      unless charset
        _doc = Nokogiri.parse(src.scrub)
        self.charset = guess_encoding(_doc)
      end
      Nokogiri::HTML(src, nil, charset)
    end

    def parse!
      self.doc = parse
      self
    end

    private

    def guess_encoding(_doc)
      _charset = _doc.xpath('//meta/@charset').first
      return _charset.value.to_s if charset

      _charset = _doc.xpath('//meta').each do |m|
        if content_tag?(m)
          return m.attribute('content').value.split('charset=').last.strip
        end
      end

      'UTF-8'
    end

    def content_tag?(m)
      m.attribute('http-equiv') &&
        m.attribute('content') &&
        m.attribute('http-equiv').value.casecmp('Content-Type')
    end

  end
end
