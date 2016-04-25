module Ogo
  class Parser

    attr_reader :page, :page_data

    def initialize(parseable)
      src = \
        if parseable.include?('</html>')
          parseable
        else
          _rf = Ogo::Utils::RedirectFollower.new(parseable)
          _rf.resolve
        end
      @page = Ogo::PageSource.new(src).parse!
      @page_data = {}
    end

    def images
    end

    def title
    end

    def description
    end

  end
end
