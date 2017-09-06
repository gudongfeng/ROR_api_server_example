# spec/support/request_helpers.rb
module Requests
  module JsonHelpers
    def json
      JSON.parse(response.body)
    end

    def add_authenticate_header token
      headers = { Authorization: token }
      request.headers.merge! headers
    end
  end
end