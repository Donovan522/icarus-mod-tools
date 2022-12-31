# frozen_string_literal: true

module Icarus
  module Mod
    module CLI
      # Sync CLI command definitions
      class Sync < SubCommandBase
        desc "modinfo", "Reads from 'meta/repos/list' and Syncs any modinfo files we find (github only for now)"
        def modinfo
          puts "Building modinfo list..."
        end

        desc "mods", "Reads from 'meta/modinfo/list' and updates the 'mods' database accordingly"
        def mods
          puts "Syncing Mods with ModInfo..."
        end
      end
    end
  end
end
