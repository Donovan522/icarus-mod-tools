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

        def mods
          @firestore.mods
        end

        def modinfo_array
          @modinfo_array ||= @firestore.modinfo_array.map do |url|
            retrieve_from_url(url)[:mods].map { |mod| Modinfo.new(mod) }
          rescue Icarus::Mod::Tools::RequestFailed
            warn "Skipped; Failed to retrieve #{url}"
            next
          rescue JSON::ParserError => e
            warn "Skipped; Invalid JSON: #{e.full_message}"
            next
          end.flatten.compact
        end

        def find_mod(modinfo)
          @firestore.find_mod(name: modinfo.name, author: modinfo.author)&.id
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
