require 'addressable/uri'
require_relative 'ogo/opengraph'
require_relative 'ogo/utils/redirect_follower'

module Ogo

  def self.parse_opengraph(url)
    og = Ogo::Opengraph.new(url)
    og.parse
    og
  end

end
