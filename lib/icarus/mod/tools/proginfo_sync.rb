# frozen_string_literal: true

require "firestore"
require "github"
require "tools/sync_helpers"

module Icarus
  module Mod
    module Tools
      # Sync methods
      class ProginfoSync
        include SyncHelpers

        def initialize
          @firestore = Firestore.new
          @github = Github.new
          @repositories = []
        end

        def repositories
          @firestore.repos
        end

        def update(proginfo_array)
          @firestore.update(:proginfo, proginfo_array)
        end

        def proginfo(url)
          retrieve_from_url(url)
        end

        def data(repositories, verbose: false)
          repositories.map do |repo|
            print "searching #{repo}..." if verbose

            case repo
            when /github/
              @github.repository = repo
              proginfo_url = @github.find("proginfo.json")

              unless proginfo_url
                puts "Skipped...no proginfo.json" if verbose
                next
              end

              puts "Found!" if verbose
              proginfo_url
            else
              puts "Skipped...repository type not supported yet" if verbose
            end
          end.compact
        end
      end
    end
  end
end
