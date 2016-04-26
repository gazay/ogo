module Ogo
  class Parser

    attr_reader :page, :page_data, :url

    def initialize(parseable)
      src = \
        if parseable.include?('</html>')
          @url = ''
          parseable
        else
          @url = parseable
          Ogo::Utils::RedirectFollower.new(@url).resolve
        end
      @page = Ogo::PageSource.new(src).parse!
      @page_data = {}
    end

    def title
      @title ||= \
        begin
          title_tag = page.doc.xpath("//head//title").first
          title_tag && title_tag.text.to_s.strip
        end
    end

    def description
      @description ||= \
        begin
          description_meta = doc.xpath("//head//meta[@name='description']").first
          _desc = description_meta && description_meta.attribute("content").to_s.strip
          if !_desc || _desc.empty?
            _desc = fetch_first_text
          end
          _desc
        end
    end

    private

    def fetch_first_text
      page.doc.xpath('//p').each do |p|
        s = p.text.to_s.strip
        return s if s.length > 20
      end
    end

    def fetch_images(doc, xpath_str, attr)
      doc.xpath(xpath_str).each do |link|
        add_image(link.attribute(attr).to_s.strip)
      end
    end

  end
end
