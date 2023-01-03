# frozen_string_literal: true

require "tools/modinfo_sync"
require "tools/mod_sync"

module Icarus
  module Mod
    module CLI
      # Sync CLI command definitions
      class Sync < SubcommandBase
        desc "modinfo", "Reads from 'meta/repos/list' and Syncs any modinfo files we find (github only for now)"
        def modinfo
          modinfo_sync = Icarus::Mod::Tools::ModinfoSync.new

          puts "Retrieving repository Data..." if verbose?
          repositories = modinfo_sync.repositories

          raise Icarus::Mod::Tools::Error, "Unable to find any repositories!" unless repositories.any?

          puts "Retrieving modinfo Array..." if verbose?
          modinfo_array = modinfo_sync.modinfo_data(repositories, verbose: verbose > 1)&.map(&:download_url)&.compact

          raise Icarus::Mod::Tools::Error, "Unable to find any modinfo.json files!" unless modinfo_array&.any?

          puts "Saving to Firestore..." if verbose?
          response = modinfo_sync.update(modinfo_array)
          puts response ? "Success" : "Failure (may be no changes)" if verbose?
        end

        desc "mods", "Reads from 'meta/modinfo/list' and updates the 'mods' database accordingly"
        def mods
          modsync = Icarus::Mod::Tools::ModSync.new

          puts "Retrieving modinfo Data..." if verbose?
          modinfo_array = modsync.modinfo_array

          puts "Retrieving mod Data..." if verbose?
          mod_array = modsync.mods

          puts "Updating mod Data..." if verbose?
          modinfo_array.each do |mod|
            verb = "Creating"
            doc_id = modsync.find_mod(mod)

            if doc_id
              puts "Found existing mod #{mod.name} at #{doc_id}" if verbose > 2
              mod.id = doc_id
              verb = "Updating"
            end

            print format("#{verb} %-<name>60s", name: "'#{mod.author || "NoOne"}/#{mod.name || "Unnamed"}'") if verbose > 1
            response = modsync.update(mod)
            puts format("%<status>10s", status: response ? "Success" : "Failure") if verbose > 1
          end

          puts "Created/Updated #{modinfo_array.count} mods" if verbose?

          delete_array = mod_array.filter { |mod| modsync.find_modinfo(mod).nil? }

          return unless delete_array.any?

          puts "Deleting outdated mods..." if verbose?
          delete_array.each do |mod|
            print format("Deleting %-<name>60s", name: "'#{mod.author || "NoOne"}/#{mod.name || "Unnamed'"}") if verbose > 1
            response = modsync.delete(mod)
            puts format("%<status>10s", status: response ? "Success" : "Failure") if verbose > 1
          end

          puts "Deleted #{delete_array.count} outdated mods" if verbose?
        rescue Icarus::Mod::Tools::Error => e
          warn e.message
          exit 1
        end
      end
    end
  end
end
