module Sawyer

  class HalLinksParser

    def parse(data)
      links = data.delete(:_links)

      return data, links
    end

  end

end
