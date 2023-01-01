# frozen_string_literal: true

require "uri"
require "net/http"
require "json"

module Icarus
  module Mod
    module Tools
      # Sync helper methods
      module SyncHelpers
        def retrieve_from_url(url)
          res = Net::HTTP.get_response(URI(url))

          raise "HTTP Request failed (#{res.code}): #{res.message}" unless res&.code == "200"

          JSON.parse(res.body, symbolize_names: true)
        end
      end
    end
  end
end
