require 'net/http'

module Ogo
  module Utils
    class RedirectFollower
      REDIRECT_DEFAULT_LIMIT = 5
      HTTP_DEFAULT_TIMEOUT = 3 # seconds

      class TooManyRedirects < StandardError; end
      class EmptyURLError < ArgumentError; end

      attr_accessor :url, :body, :charset, :redirect_limit, :http_timeout,
        :response, :headers

      def initialize(url, options = {})
        raise EmptyURLError if url.to_s.empty?
        @redirect_limit = options[:redirect_limit] ||
                          Ogo.config[:redirect_limit] ||
                          REDIRECT_DEFAULT_LIMIT
        @http_timeout = options[:http_timeout] ||
                        Ogo.config[:http_timeout] ||
                        HTTP_DEFAULT_TIMEOUT
        @headers = options[:headers] || {}
        @url = url.start_with?('http') ? url : "http://#{url}"
      end

      def resolve
        raise TooManyRedirects if redirect_limit < 0

        uri = Addressable::URI.parse(url).normalize

        http = Net::HTTP.new(uri.host, uri.inferred_port)
        http.read_timeout = http_timeout
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
