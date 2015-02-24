module Hurley
  class Client
    def url_prefix=(endpoint)
      @url = Url.parse(endpoint)
    end
  end

  class Request
    alias :params :query
    alias :headers :header
  end

  class Response
    alias :status :status_code
    alias :headers :header
  end
end
