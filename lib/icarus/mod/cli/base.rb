# frozen_string_literal: true

require "version"
require "tools"
require "thor"

module Icarus
  module Mod
    module CLI
      # Base class for all subcommands
      class SubCommandBase < Thor
        class_option :verbose,
                     aliases: "-v",
                     type: :boolean,
                     repeatable: true,
                     default: [true],
                     desc: "Increase verbosity. May be repeated for even more verbosity."

        no_commands do
          def check_false
            options[:verbose] = [] if options[:verbose].include?(false)
          end

          def verbose
            check_false
            options[:verbose]&.count || 0
          end

          def verbose?
            check_false
            options[:verbose]&.count&.positive?
          end
        end

        # rubocop:disable Style/OptionalBooleanParameter
        def self.banner(command, _namespace = nil, _subcommand = false)
          "#{basename} #{subcommand_prefix} #{command.usage}"
        end
        # rubocop:enable Style/OptionalBooleanParameter

        def self.subcommand_prefix
          name.gsub(/.*::/, "").gsub(/^[A-Z]/) { |match| match[0].downcase }.gsub(/[A-Z]/) { |match| "-#{match[0].downcase}" }
        end
      end

      # Require subcommands after the SubCommandBase class is defined
      require "cli/sync"
      require "cli/list"
      require "cli/add"

      # The main CLI for Icarus Mod Tools
      class Base < Thor
        def self.exit_on_failure?
          true
        end

        map %w[--version -V] => :__print_version

        desc "--version, -V", "print the version and exit"
        def __print_version
          puts "IcarusModTool (imt) v#{Icarus::Mod::VERSION}"
        end

        desc "sync", "Syncs the databases"
        subcommand "sync", Sync

        desc "list", "Lists the databases"
        subcommand "list", List

        desc "add", "Adds entries to the databases"
        subcommand "add", Add
      end
    end
  end
end
