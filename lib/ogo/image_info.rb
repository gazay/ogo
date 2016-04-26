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
    end

  end
end
