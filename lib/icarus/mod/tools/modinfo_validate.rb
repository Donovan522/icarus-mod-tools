# frozen_string_literal: true

module Icarus
  module Mod
    module Tools
      # Validate Methods
      class ModinfoValidate
        attr_reader :modinfo_array

        def initialize
          @modinfo_array = ModSync.new.modinfo_array
        end
      end
    end
  end
end
