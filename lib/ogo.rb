require 'addressable/uri'
require 'uri'
require 'nokogiri'

require_relative 'ogo/page_source'
require_relative 'ogo/image_info'
require_relative 'ogo/parsers'
require_relative 'ogo/utils/redirect_follower'
require_relative 'ogo/version'

module Ogo

  def self.parse_opengraph(url)
    og = Ogo::Opengraph.new(url)
    og.parse
    og
  end

end
