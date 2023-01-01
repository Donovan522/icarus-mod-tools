# frozen_string_literal: true

require "firestore"

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
      end
    end
  end
end
