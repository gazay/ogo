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

    def image
      all_images.first
    end

    def all_images
      @all_images ||= \
        begin
          imgs = (
            fetch_images("//head//link[@rel='image_src']", "href") +
            fetch_images("//img", "src")
          ).flatten.compact.uniq
          imgs.map { |img| Ogo::ImageInfo.new(url: img) }
        end
    end

    private

    def fetch_first_text
      page.doc.xpath('//p').each do |p|
        s = p.text.to_s.strip
        return s if s.length > 20
      end
    end

    def fetch_images(xpath_str, attr)
      page.doc.xpath(xpath_str).map do |tag|
        link.attribute(attr).to_s.strip
      end.reject { |it| it.empty? }.uniq
    end

  end
end
