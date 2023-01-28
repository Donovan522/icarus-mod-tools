# frozen_string_literal: true

require "firestore"
require "tools/sync/helpers"

module Icarus
  module Mod
    module Tools
      module Sync
        # Sync methods
        class Progs
          include Helpers

          def initialize(client: nil)
            @firestore = client || Firestore.new
          end

          def progs
            @firestore.progs
          end

          def info_array
            @info_array ||= @firestore.proginfo.map do |url|
              retrieve_from_url(url)[:programs].map { |prog| Tools::Proginfo.new(prog) if prog[:name] =~ /[a-z0-9]+/i }
            rescue Icarus::Mod::Tools::Sync::RequestFailed
              warn "Skipped; Failed to retrieve #{url}"
              next
            rescue JSON::ParserError => e
              warn "Skipped; Invalid JSON: #{e.full_message}"
              next
            end.flatten.compact
          end

          def find(proginfo)
            @firestore.find_by_type(type: "progs", name: proginfo.name, author: proginfo.author)&.id
          end

          def find_info(proginfo)
            @info_array.find { |prog| prog.name == proginfo.name }
          end

          def update(proginfo)
            @firestore.update(:prog, proginfo, merge: false)
          end

          def delete(proginfo)
            @firestore.delete(:prog, proginfo)
          end
        end
      end
    end
  end
end
