# frozen_string_literal: true

require "tools/baseinfo"

module Icarus
  module Mod
    module Tools
      # Sync methods
      class Proginfo < Baseinfo
        # rubocop:disable Naming/MethodName
        def fileType
          @data[:fileType] || "zip"
        end
        # rubocop:enable Naming/MethodName
      end
    end
  end
end
