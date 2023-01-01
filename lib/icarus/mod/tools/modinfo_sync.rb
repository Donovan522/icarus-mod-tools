# frozen_string_literal: true

require "firestore"
require "github"
require "uri"
require "net/http"
require "json"
require "tools/sync_helpers"

module Icarus
  module Mod
    module Tools
      # Sync methods
      class ModinfoSync
        include SyncHelpers

        def initialize
          @firestore = Firestore.new
          @github = Github.new
          @repositories = []
        end

        def repositories
          @firestore.repos
        end

        def update_modinfo_list(modinfo_array)
          resp = @firestore.update_modinfo_list(modinfo_array)

          raise "Failed to save data to Firestore!" unless (Time.now - resp.update_time) < 10
        end

        def modinfo(url)
          retrieve_from_url(url)
        end

        def modinfo_data(repositories, verbose: false)
          repositories.map do |repo|
            print "searching #{repo}..." if verbose

            case repo
            when /github/
              @github.repository = repo
              modinfo = @github.find("modinfo.json")

              unless modinfo
                puts "Skipped...no modinfo.json" if verbose
                next
              end

              puts "Found!" if verbose
              modinfo
            else
              puts "Skipped...repository type not supported yet" if verbose
            end
          end.compact
        end
      end
    end
  end
end
