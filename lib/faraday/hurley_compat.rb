module Faraday
  class Request
    alias :query :params
    alias :header :headers
  end

  class Response
    alias :status_code :status
    alias :header :headers
  end
end
