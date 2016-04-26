module Ogo
  module Parsers
    class Base

      attr_reader :page, :url

      def initialize(parseable)
        @page = \
          if parseable.include?('</html>')
            @url = ''
            Ogo::PageSource.new(parseable).parse!
          else
            _rf = Ogo::Utils::RedirectFollower.new(parseable).resolve
            page = Ogo::PageSource.new(_rf.body, charset: _rf.charset, url: _rf.url)
            @url = _rf.url
            page.parse!
          end
        @type = 'website'
      end

      def title(fallback=false)
        title_tag = page.doc.xpath('//head//title').first
        title_tag && title_tag.text.to_s.strip
      end

      def description(fallback=false)
        description_meta = page.doc.xpath("//head//meta[@name='description']").first
        _desc = description_meta && description_meta.attribute("content").to_s.strip
        if !_desc || _desc.empty?
          _desc = fetch_first_text
        end
        _desc
      end

      def image(fallback=false)
        all_images.first
      end

      def type(fallback=false)
        @type
      end

      def all_images
        @all_images ||= \
          begin
            imgs = (
              fetch_images("//head//meta[@itemprop='image']", "content") +
              fetch_images("//head//meta[@itemprop='logo']", "content") +
              fetch_images("//head//meta[@property='og:image']", "content") +
              fetch_images("//head//meta[@property='twitter:image:src']", "content") +
              fetch_images("//head//link[@rel='image_src']", "href") +
              fetch_images("//img", "src")
            ).flatten.compact.uniq
            host_uri = Addressable::URI.parse(url)
            imgs.map { |img|
              Ogo::ImageInfo.new(url: fix_image_path(img, host_uri))
            }
          end
      end

      def metadata(fallback=false)
        _meta = {
          title: title,
          description: description,
          type: type,
          image: nil
        }
        if image
          _meta[:image] = {
            url:    image.url,
            width:  image.width,
            height: image.height,
            type:   image.type
          }
        end
        _meta
      end

      private

      def fix_image_path(img, host_uri)
        return "http:#{img}" if img.start_with?('//')
        return img if host_uri.host.nil?
        if Addressable::URI.parse(img).host.nil?
          host_uri.join(img).to_s
        else
          img
        end
      end

      def fetch_first_text
        page.doc.xpath('//p').each do |p|
          s = p.text.to_s.strip
          return s if s.length > 20
        end
      end

      def fetch_images(xpath_str, attr)
        page.doc.xpath(xpath_str).map do |tag|
          tag.attribute(attr).to_s.strip
        end.reject { |it| it.empty? }.uniq
      end

    end
  end
end
