# frozen_string_literal: true

require "tools/modinfo_sync"
require "tools/proginfo_sync"
require "tools/mod_sync"
require "tools/prog_sync"

module Icarus
  module Mod
    module CLI
      # Sync CLI command definitions
      class Sync < SubcommandBase
        class_option :dry_run, type: :boolean, default: false, desc: "Dry run (no changes will be made)"

        desc "all", "Run all sync jobs"
        def all
          invoke :proginfo
          invoke :progs
          invoke :modinfo
          invoke :mods
        end

        desc "modinfo", "Reads from 'meta/repos/list' and Syncs any modinfo files we find (github only for now)"
        def modinfo
          modinfo_sync = Icarus::Mod::Tools::ModinfoSync.new

          puts "Retrieving repository Data..." if verbose?
          repositories = modinfo_sync.repositories

          raise Icarus::Mod::Tools::Error, "Unable to find any repositories!" unless repositories.any?

          puts "Retrieving modinfo Array..." if verbose?
          modinfo_array = modinfo_sync.modinfo_data(repositories, verbose: verbose > 1)&.map(&:download_url)&.compact

          raise Icarus::Mod::Tools::Error, "No modinfo.json files found" unless modinfo_array&.any?

          if options[:dry_run]
            puts "Dry run; no changes will be made"
            return
          end

          puts "Saving to Firestore..." if verbose?
          response = modinfo_sync.update(modinfo_array)
          puts response ? "Success" : "Failure (may be no changes)" if verbose?
        rescue Icarus::Mod::Tools::Error => e
          warn e.message
        end

        desc "proginfo", "Reads from 'meta/repos/list' and Syncs any proginfo files we find (github only for now)"
        def proginfo
          proginfo_sync = Icarus::Mod::Tools::ProginfoSync.new

          puts "Retrieving repository Data..." if verbose?
          repositories = proginfo_sync.repositories

          raise Icarus::Mod::Tools::Error, "Unable to find any repositories!" unless repositories.any?

          puts "Retrieving proginfo Array..." if verbose?
          proginfo_array = proginfo_sync.proginfo_data(repositories, verbose: verbose > 1)&.map(&:download_url)&.compact

          raise Icarus::Mod::Tools::Error, "no proginfo.json files found" unless proginfo_array&.any?

          if options[:dry_run]
            puts "Dry run; no changes will be made"
            return
          end

          puts "Saving to Firestore..." if verbose?
          response = proginfo_sync.update(proginfo_array)
          puts response ? "Success" : "Failure (may be no changes)" if verbose?
        rescue Icarus::Mod::Tools::Error => e
          warn e.message
        end

        desc "mods", "Reads from 'meta/modinfo/list' and updates the 'mods' database accordingly"
        method_option :check, type: :boolean, default: false, desc: "Validate modinfo without applying changes"
        def mods
          modsync = Icarus::Mod::Tools::ModSync.new

          puts "Retrieving modinfo Data..." if verbose?
          modinfo_array = modsync.modinfo_array

          puts "Retrieving mod Data..." if verbose?
          mod_array = modsync.mods

          return if options[:check]

          puts "Updating mod Data..." if verbose?
          modinfo_array.each do |mod|
            verb = "Creating"

            puts "Validating modinfo Data for #{mod.uniq_name}..." if verbose > 2
            warn "Skipping mod #{mod.uniq_name} due to validation errors" && next unless mod.validate

            doc_id = modsync.find_mod(mod)
            if doc_id
              puts "Found existing mod #{mod.name} at #{doc_id}" if verbose > 2
              mod.id = doc_id
              verb = "Updating"
            end

            print format("#{verb} %-<name>60s", name: "'#{mod.author || "NoOne"}/#{mod.name || "Unnamed"}'") if verbose > 1

            if options[:dry_run]
              puts "Dry run; no changes will be made" if verbose > 1
              next
            end

            response = modsync.update(mod)
            puts format("%<status>10s", status: response ? "Success" : "Failure") if verbose > 1
          end

          if options[:dry_run]
            puts "Dry run; no changes will be made" if verbose?
            return
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
        end

        desc "progs", "Reads from 'meta/proginfo/list' and updates the 'progs' database accordingly"
        method_option :check, type: :boolean, default: false, desc: "Validate proginfo without applying changes"
        def progs
          progsync = Icarus::Mod::Tools::ProgSync.new

          puts "Retrieving proginfo Data..." if verbose?
          proginfo_array = progsync.proginfo_array

          puts "Retrieving progs Data..." if verbose?
          prog_array = progsync.progs

          return if options[:check]

          puts "Updating Program Data..." if verbose?
          proginfo_array.each do |prog|
            verb = "Creating"

            puts "Validating proginfo Data for #{prog.uniq_name}..." if verbose > 2
            warn "Skipping program #{prog.uniq_name} due to validation errors" && next unless prog.validate

            doc_id = progsync.find_prog(prog)
            if doc_id
              puts "Found existing program #{prog.name} at #{doc_id}" if verbose > 2
              prog.id = doc_id
              verb = "Updating"
            end

            print format("#{verb} %-<name>60s", name: "'#{prog.author || "NoOne"}/#{prog.name || "Unnamed"}'") if verbose > 1

            if options[:dry_run]
              puts "Dry run; no changes will be made" if verbose > 1
              next
            end

            response = progsync.update(prog)
            puts format("%<status>10s", status: response ? "Success" : "Failure") if verbose > 1
          end

          if options[:dry_run]
            puts "Dry run; no changes will be made" if verbose?
            return
          end

          puts "Created/Updated #{proginfo_array.count} Programs" if verbose?

          delete_array = prog_array.filter { |prog| progsync.find_proginfo(prog).nil? }

          return unless delete_array.any?

          puts "Deleting outdated programs..." if verbose?
          delete_array.each do |prog|
            print format("Deleting %-<name>60s", name: "'#{prog.author || "NoOne"}/#{prog.name || "Unnamed'"}") if verbose > 1
            response = progsync.delete(prog)
            puts format("%<status>10s", status: response ? "Success" : "Failure") if verbose > 1
          end

          puts "Deleted #{delete_array.count} outdated programs" if verbose?
        rescue Icarus::Mod::Tools::Error => e
          warn e.message
        end
      end
    end
  end
end
