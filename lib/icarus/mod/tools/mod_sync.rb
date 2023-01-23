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

        def info_array
          @info_array ||= @firestore.modinfo_list.map do |url|
            retrieve_from_url(url)[:mods].map { |mod| Modinfo.new(mod) if mod[:name] =~ /[a-z0-9]+/i }
          rescue Icarus::Mod::Tools::RequestFailed
            warn "Skipped; Failed to retrieve #{url}"
            next
          rescue JSON::ParserError => e
            warn "Skipped; Invalid JSON: #{e.full_message}"
            next
          end.flatten.compact
        end

        def find(modinfo)
          @firestore.find_by_type(type: "mods", name: modinfo.name, author: modinfo.author)&.id
        end

        def find_info(modinfo)
          @info_array.find { |mod| mod.name == modinfo.name }
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
