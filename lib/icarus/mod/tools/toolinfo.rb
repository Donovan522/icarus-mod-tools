# frozen_string_literal: true

require "tools/baseinfo"

module Icarus
  module Mod
    module Tools
      # Sync methods
      class Toolinfo < Baseinfo
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
