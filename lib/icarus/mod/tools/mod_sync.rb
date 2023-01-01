# frozen_string_literal: true

require "firestore"
require "tools/sync_helpers"

module Icarus
  module Mod
    module Tools
      # Sync methods
      class ModSync
        include SyncHelpers

        def initialize
          @firestore = Firestore.new
        end

        def self.sync
          new.sync
        end

        def mods
          @firestore.mods
        end

        def modinfo_array
          @modinfo_array ||= @firestore.modinfo_array.map do |url|
            retrieve_from_url(url)[:mods].map { |mod| Modinfo.new(mod) }
          end.flatten
        end

        def find_mod(modinfo)
          @firestore.find_mod(:name, modinfo.name)&.id
        end

        def find_modinfo(modinfo)
          @modinfo_array.find { |mod| mod.name == modinfo.name }
        end

        def update(modinfo)
          @firestore.update(:mod, modinfo, merge: false)
        end

        def delete(modinfo)
          @firestore.delete(:mod, modinfo)
        end
      end
    end
  end
end
