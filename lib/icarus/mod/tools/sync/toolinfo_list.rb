# frozen_string_literal: true

require "firestore"
require "github"
require "tools/sync/helpers"

module Icarus
  module Mod
    module Tools
      module Sync
        # Sync methods
        class ToolinfoList
          include Helpers

          def initialize(client: nil)
            @firestore = client || Firestore.new
            @github = Github.new
            @repositories = []
          end

          def repositories
            @firestore.repositories
          end

          def update(toolinfo_array)
            @firestore.update(:toolinfo, toolinfo_array)
          end

          def toolinfo(url)
            retrieve_from_url(url)
          end

          def data(repositories, verbose: false)
            repositories.map do |repo|
              print "searching #{repo}..." if verbose

              case repo
              when /github/
                @github.repository = repo
                toolinfo_url = @github.find("toolinfo.json")

                unless toolinfo_url
                  puts "Skipped...no toolinfo.json" if verbose
                  next
                end

                puts "Found!" if verbose
                toolinfo_url
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
