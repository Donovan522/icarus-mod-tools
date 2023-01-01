# frozen_string_literal: true

require "tools/modinfo_sync"

module Icarus
  module Mod
    module CLI
      # Sync CLI command definitions
      class Sync < SubCommandBase
        desc "modinfo", "Reads from 'meta/repos/list' and Syncs any modinfo files we find (github only for now)"
        method_option :verbose,
                      aliases: "-v",
                      type: :boolean,
                      repeatable: true,
                      default: [],
                      desc: "Verbose output (default false). May be repeated for more verbosity."
        def modinfo
          verbose = options[:verbose]&.count || 0

          modinfo_sync = Icarus::Mod::Tools::ModinfoSync.new

          puts "Retrieving repository Data..." if verbose
          repositories = modinfo_sync.repositories

          raise "Unable to find any repositories!" unless repositories.any?

          puts "Retrieving modinfo Array..." if verbose
          modinfo_array = modinfo_sync.modinfo_data(repositories, verbose: verbose > 1)&.map(&:download_url)&.compact

          raise "Unable to find any modinfo.json files!" unless modinfo_array&.any?

          puts "Saving to Firestore..." if verbose
          resp = modinfo_sync.update(modinfo_array)
          puts resp ? "Success" : "Failure (may be no changes)" if verbose
        end

        desc "mods", "Reads from 'meta/modinfo/list' and updates the 'mods' database accordingly"
        def mods
          puts "Syncing Mods with ModInfo..."
        end
      end
    end
  end
end
