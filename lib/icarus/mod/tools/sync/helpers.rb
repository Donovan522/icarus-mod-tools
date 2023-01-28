# frozen_string_literal: true

require "uri"
require "net/http"
require "json"

module Icarus
  module Mod
    module Tools
      module Sync
        class RequestFailed < StandardError; end

        # Sync helper methods
        module Helpers
          def retrieve_from_url(url)
            raise RequestFailed, "Invalid URI: '#{url}'" unless url && url =~ URI::DEFAULT_PARSER.make_regexp

            res = Net::HTTP.get_response(URI(url))

            raise RequestFailed, "HTTP Request failed for #{url} (#{res.code}): #{res.message}" unless res&.code == "200"

            JSON.parse(res.body, symbolize_names: true)
          end
        end
      end
    end
  end
end
