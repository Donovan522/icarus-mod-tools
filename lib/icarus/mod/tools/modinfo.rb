# frozen_string_literal: true

require "tools/baseinfo"

module Icarus
  module Mod
    module Tools
      # Sync methods
      class Modinfo < Baseinfo
        HASHKEYS = %i[name author version compatibility description long_description files fileType fileURL imageURL readmeURL].freeze

        def to_h
          HASHKEYS.each_with_object({}) do |key, hash|
            next if key == :files && @data[:files].nil?
            next if %i[fileType fileURL].include?(key.to_sym) && !@data[:files].nil?
            next if key == :long_description && @data[:long_description].nil?

            hash[key] = @data[key]
          end
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
