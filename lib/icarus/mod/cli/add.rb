# frozen_string_literal: true

require "firestore"

module Icarus
  module Mod
    module CLI
      # Sync CLI command definitions
      class Add < SubcommandBase
        desc "modinfo", "Adds an entry to 'meta/modinfo/list'"
        def modinfo(item)
          firestore = Firestore.new
          payload = [firestore.list(:modinfo), item].flatten.compact

          puts firestore.update(:modinfo, payload, merge: true) ? "Success" : "Failure"
        end

        desc "repos", "Adds an entry to 'meta/repos/list'"
        def repos(item)
          firestore = Firestore.new
          payload = [firestore.list(:repositories), item].flatten.compact

          puts firestore.update(:repositories, payload, merge: true) ? "Success" : "Failure"
        end
      end
    end
  end
end
