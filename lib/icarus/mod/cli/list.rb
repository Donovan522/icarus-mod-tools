# frozen_string_literal: true

require "firestore"
require "tools/modinfo"

module Icarus
  module Mod
    module CLI
      # Sync CLI command definitions
      class List < SubCommandBase
        desc "modinfo", "Displays data from 'meta/modinfo/list'"
        def modinfo
          puts Firestore.new.list(:modinfo)
        end

        desc "repos", "Displays data from 'meta/repos/list'"
        def repos
          puts Firestore.new.list(:repositories)
        end

        desc "mods", "Displays data from 'mods'"
        method_option :sort, type: :string, default: "name", desc: "Sort by field (name, author, etc.) - defaults to 'name'"
        def mods
          raise "Invalid sort field '#{options[:sort]}'" unless (Icarus::Mod::Tools::Modinfo::HASHKEYS + [:updated_at]).include?(options[:sort].to_sym)

          sort_field = options[:sort].to_sym
          header_format = "%-<name>50s %-<author>20s %-<version>10s %-<updated_at>20s"
          header_format += " %-<id>20s %<description>s" if verbose > 1

          if verbose?
            puts format(
              header_format,
              name: "NAME",
              author: "AUTHOR",
              version: "VERSION",
              updated_at: "LAST UPDATED",
              id: "ID",
              description: "DESCRIPTION"
            )
          end

          mods = Firestore.new.list(:mods)

          # Sort by field, optionally subsorting by name
          (sort_field == :name ? mods.sort_by(&:name) : mods.sort_by { |mod| [mod.send(sort_field), mod.name] }).each do |mod|
            data_format = "%-<name>50s %-<author>20s v%-<version>10s%-<updated_at>20s"
            data_format += " %-<id>20s %<description>s" if verbose > 1

            puts format(data_format, mod.to_h.merge(id: mod.id, updated_at: mod.updated_at.strftime("%Y-%m-%d %H:%M:%S")))
          end

          puts "Total: #{mods.count}" if verbose?
        rescue StandardError => e
          puts e.message
          exit 1
        end
      end
    end
  end
end
