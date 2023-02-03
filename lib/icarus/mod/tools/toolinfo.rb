# frozen_string_literal: true

require "tools/baseinfo"

module Icarus
  module Mod
    module Tools
      # Sync methods
      class Toolinfo < Baseinfo
        HASHKEYS = %i[name author version compatibility description fileType fileURL imageURL readmeURL].freeze

        # rubocop:disable Naming/MethodName
        def fileType
          @data[:fileType] || "zip"
        end
        # rubocop:enable Naming/MethodName

        private

        def filetype_pattern
          /(zip|exe)/i
        end
      end
    end
  end
end
