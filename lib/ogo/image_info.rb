module Ogo
  class ImageInfo

    attr_accessor :url, :width, :height, :type

    def initialize(opts={})
      @url    = opts[:url]
      @width  = opts[:width]
      @height = opts[:height]
      @type   = opts[:type]
    end

    def fetch_size
      return if @width && @height
      if defined?(FastImage)
        @width, @height = fi_check(:size, url)
      else
        []
      end
    end

    def fetch_size!
      @width, @height = nil
      fetch_size
    end

    def fetch_type
      @type ||= \
        if defined?(FastImage)
          fi_check(:type, url).to_s
        else
          uri = Addressable::URI.parse(url).normalize
          uri.path.split('.').last.to_s
        end
    end

    def fetch_type!
      @type = nil
      fetch_type
    end

    def content_type
      "image/#{fetch_type}"
    end

    private

    def fi_check(method, url, options=nil)
      options ||= {raise_on_failure: true, timeout: 2.0}
      FastImage.send(method, url, options)
    rescue
      url = Addressable::URI.parse(url).normalize
      val = FastImage.send(method, url, options)
      @url = url
      val
    end

  end
end
