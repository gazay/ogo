require 'addressable/uri'
require 'uri'
require 'nokogiri'

require_relative 'ogo/page_source'
require_relative 'ogo/image_info'
require_relative 'ogo/parsers'
require_relative 'ogo/utils/redirect_follower'
require_relative 'ogo/version'

module Ogo
  @config = {
    redirect_limit: 5,
    http_timeout: 3
  }

  def self.config
    @config
  end

  def self.parse_opengraph(url, fallback=true)
    og = Ogo::Parsers::Opengraph.new(url)
    og.metadata(fallback)
  end

end
