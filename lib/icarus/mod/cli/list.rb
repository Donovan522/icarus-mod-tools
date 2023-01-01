# frozen_string_literal: true

require "firestore"
require "tools/modinfo"

module Icarus
  module Mod
    module CLI
      # Sync CLI command definitions
      class List < SubCommandBase
        desc "modinfo", "Displays data from 'meta/modinfo/list'"
        def modinfo
          puts Firestore.new.list(:modinfo)
        end

        desc "repos", "Displays data from 'meta/repos/list'"
        def repos
          puts Firestore.new.list(:repositories)
        end

        desc "mods", "Displays data from 'mods'"
        def mods
          Firestore.new.list(:mods).each do |mod|
            puts format(
              "%-<name>50s %-<author>20s v%-<version>10s %<description>s",
              name: mod.name, author: mod.author, version: (mod.version || "None"), description: mod.description
            )
          end
        end
      end
    end
  end
end
