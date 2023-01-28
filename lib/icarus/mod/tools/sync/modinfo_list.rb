# frozen_string_literal: true

require "firestore"
require "github"
require "tools/sync/helpers"

module Icarus
  module Mod
    module Tools
      module Sync
        # Sync methods
        class ModinfoList
          include Helpers

          def initialize(client: nil)
            @firestore = client || Firestore.new
            @github = Github.new
            @repositories = []
          end

          def repositories
            @firestore.repos
          end

          def update(modinfo_array)
            @firestore.update(:modinfo, modinfo_array)
          end

          def modinfo(url)
            retrieve_from_url(url)
          end

          def data(repositories, verbose: false)
            repositories.map do |repo|
              print "searching #{repo}..." if verbose

              case repo
              when /github/
                @github.repository = repo
                modinfo_url = @github.find("modinfo.json")

                unless modinfo_url
                  puts "Skipped...no modinfo.json" if verbose
                  next
                end

                puts "Found!" if verbose
                modinfo_url
              else
                puts "Skipped...repository type not supported yet" if verbose
              end
            end.compact
          end
        end
      end
    end
  end
end
