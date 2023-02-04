# frozen_string_literal: true

require "tools/baseinfo"

module Icarus
  module Mod
    module Tools
      # Sync methods
      class Modinfo < Baseinfo
        HASHKEYS = %i[name author version compatibility description long_description files fileType fileURL imageURL readmeURL].freeze

        def to_h
          db_hash = HASHKEYS.each_with_object({}) do |key, hash|
            next if %i[fileType fileURL].include?(key.to_sym)
            next if key == :long_description && @data[:long_description].nil?

            hash[key] = @data[key]
          end

          db_hash[:files] = { @data[:fileType].downcase.to_sym => @data[:fileURL] } if db_hash[:files].nil? && !@data[:fileType].nil?

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
