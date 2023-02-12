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

        def validate
          return true if @validated

          validate_files

          super
        end
      end
    end
  end
end
