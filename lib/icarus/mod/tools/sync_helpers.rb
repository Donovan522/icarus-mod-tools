# frozen_string_literal: true

require "firestore"
require "github"
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

          raise "HTTP Request failed (#{res.code}): #{res.message}" unless res.is_a?(Net::HTTPSuccess)

          JSON.parse(res.body)
        end
      end
    end
  end
end
