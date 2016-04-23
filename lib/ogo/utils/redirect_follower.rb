require 'net/http'

module Ogo
  module Utils
    class RedirectFollower
      REDIRECT_DEFAULT_LIMIT = 5

      class TooManyRedirects < StandardError; end
      class EmptyURLError < ArgumentError; end

      attr_accessor :url, :body, :charset, :redirect_limit, :response, :headers

      def initialize(url, options = {})
        raise EmptyURLError if url.to_s.empty?
        @redirect_limit = options[:limit] || REDIRECT_DEFAULT_LIMIT
        @headers = options[:headers] || {}
        @url = url.start_with?('http') ? url : "http://#{url}"
      end

      def resolve
        raise TooManyRedirects if redirect_limit < 0

        uri = Addressable::URI.parse(URI.escape(url))

        http = Net::HTTP.new(uri.host, uri.port)
        if uri.scheme == 'https'
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        end

        self.response = http.request_get(uri.request_uri, headers)

        if response.kind_of?(Net::HTTPRedirection)
          self.url = redirect_url
          self.redirect_limit -= 1
          resolve
        end

        charset = nil
        if content_type = response['content-type']
          if content_type =~ /charset=(.+)/i
            charset = $1
          end
        end
        self.charset = charset

        self.body = response.body
        self
      end

      def redirect_url
        if response['location'].nil?
          response.body.match(/<a href=\"([^>]+)\">/i)[1]
        else
          response['location']
        end
      end

    end
  end
end
