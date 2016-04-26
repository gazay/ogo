module Ogo
  module Parsers
    class Opengraph < Ogo::Parsers::Base

      def initialize(parseable, fallback=false)
        @global_fallback = fallback
        super parseable
      end

      def title(fallback=false)
        if fallback
          super
        else
          _val = find_meta('title')
          (!_val.empty? && _val) ||
            (@global_fallback && super) ||
            ''
        end
      end

      def description(fallback=false)
        if fallback
          super
        else
          _val = find_meta('description')
          (!_val.empty? && _val) ||
            (@global_fallback && super) ||
            ''
        end
      end

      def image(fallback=false)
        if fallback
          super
        else
          _val = find_meta('image')
          if _val.empty?
            (@global_fallback && super) || nil
          else
            host_uri = Addressable::URI.parse(url)
            Ogo::ImageInfo.new(url: fix_image_path(_val, host_uri))
          end
        end
      end

      def type(fallback=false)
        if fallback
          super
        else
          _val = find_meta('type')
          (!_val.empty? && _val) ||
            (@global_fallback && super) ||
            ''
        end
      end

      def metadata(fallback=false)
        _meta = super
        if fallback
          _meta[:fallback] = {
            title: title(true),
            description: description(true),
            type: type(true),
            image: nil
          }
          img = image(true)
          if img
            _meta[:fallback][:image] = {
              url:    img.url,
              width:  img.width,
              height: img.height,
              type:   img.type
            }
          end
        end
        _meta
      end

      private

      def find_meta(meta_type)
        tag = page.doc.xpath('//head//meta').find { |it|
          it.attribute('property').to_s == "og:#{meta_type}"
        }
        (tag && tag.attribute('content')).to_s.strip
      end

    end
  end
end
