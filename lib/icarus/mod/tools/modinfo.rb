# frozen_string_literal: true

require "tools/baseinfo"

module Icarus
  module Mod
    module Tools
      # Sync methods
      class Modinfo < Baseinfo
        def to_h
          db_hash = super
          db_hash[:meta] = { status: } # Add metadata

          db_hash
        end

        def file_types
          files&.keys || [@data[:fileType] || "pak"]
        end

        def file_urls
          files&.values || [@data[:fileURL]].compact
        end

        # rubocop:disable Naming/MethodName
        def fileType
          @data[:fileType] || "pak"
        end
        # rubocop:enable Naming/MethodName
      end
    end
  end
end
