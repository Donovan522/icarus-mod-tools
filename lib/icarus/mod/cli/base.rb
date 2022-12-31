# frozen_string_literal: true

require "tools"
require "thor"

module Icarus
  module Mod
    module CLI
      # Base class for all subcommands
      class SubCommandBase < Thor
        def self.banner(command, _namespace = nil, _subcommand = false) # rubocop:disable Style/OptionalBooleanParameter
          "#{basename} #{subcommand_prefix} #{command.usage}"
        end

        def self.subcommand_prefix
          name.gsub(/.*::/, "").gsub(/^[A-Z]/) { |match| match[0].downcase }.gsub(/[A-Z]/) { |match| "-#{match[0].downcase}" }
        end
      end

      # Require subcommands after the SubCommandBase class is defined
      require "cli/sync"

      # The main CLI for Icarus Mod Tools
      class Base < Thor
        def self.exit_on_failure?
          true
        end

        desc "sync", "Syncs the databases"
        subcommand "sync", Sync

        # desc "tools", "Runs a tool"
        # subcommand "tools", Tools
      end
    end
  end
end
