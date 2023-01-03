# frozen_string_literal: true

require "firestore"
require "tools/modinfo"

module Icarus
  module Mod
    module CLI
      # Sync CLI command definitions
      class List < SubcommandBase
        desc "modinfo", "Displays data from 'meta/modinfo/list'"
        def modinfo
          modinfos = Firestore.new.list(:modinfo)
          puts modinfos
          puts "Total: #{modinfos.count}" if verbose > 1
        end

        desc "repos", "Displays data from 'meta/repos/list'"
        def repos
          repos = Firestore.new.list(:repositories)
          puts repos
          puts "Total: #{repos.count}" if verbose > 1
        end

        desc "mods", "Displays data from 'mods'"
        method_option :sort, type: :string, default: "name", desc: "Sort by field (name, author, etc.)"
        method_option :filter, type: :array, default: [], desc: "Filter by field (name, author, etc.)"
        def mods
          valid_keys = Icarus::Mod::Tools::Modinfo::HASHKEYS + [:updated_at]

          sort_field = options[:sort]&.to_sym

          filter = !options[:filter].empty?

          if filter
            filter_field = options[:filter].first&.to_sym
            filter_value = options[:filter].last&.to_s

            raise Icarus::Mod::Tools::Error, "Invalid filter option #{options[:filter]}" unless options[:filter].empty? || options[:filter]&.count == 2

            raise Icarus::Mod::Tools::Error, "Invalid filter field '#{filter_field}'" unless filter_field && valid_keys.include?(filter_field)
          end

          raise Icarus::Mod::Tools::Error, "Invalid sort field '#{sort_field}'" unless valid_keys.include?(sort_field)

          puts "Sorted by #{sort_field}" if sort_field && verbose > 2
          puts "Filtered by #{filter_field} = #{filter_value}" if filter_field && verbose > 2

          mods = Firestore.new.list(:mods)

          # Filter by field
          mods.select! { |mod| mod.send(filter_field).downcase =~ /#{filter_value&.downcase}/ } if filter_field

          if mods.empty?
            puts "no mods found" if verbose?
            return
          end

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

          # Sort by field, optionally subsorting by name
          (sort_field == :name ? mods.sort_by(&:name) : mods.sort_by { |mod| [mod.send(sort_field), mod.name] }).each do |mod|
            data_format = "%-<name>50s %-<author>20s v%-<version>10s%-<updated_at>20s"
            data_format += " %-<id>20s %<description>s" if verbose > 1

            puts format(data_format, mod.to_h.merge(id: mod.id, updated_at: mod.updated_at.strftime("%Y-%m-%d %H:%M:%S")))
          end

          puts "Total: #{mods.count}" if verbose?
        rescue Icarus::Mod::Tools::Error => e
          puts e.message
          exit 1
        end
      end
    end
  end
end
