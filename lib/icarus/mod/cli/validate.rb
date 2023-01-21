# frozen_string_literal: true

require "tools/modinfo_validate"

module Icarus
  module Mod
    module CLI
      # Sync CLI command definitions
      class Validate < SubcommandBase
        desc "modinfo", "Reads modinfo data from 'meta/modinfo/list' and Validates syntax of modfiles"
        def modinfo
          exit_code = 0
          modinfo_validate = Icarus::Mod::Tools::ModinfoValidate.new

          puts "Validating Entries..." if verbose?
          max_length = modinfo_validate.modinfo_array.map { |modinfo| modinfo.uniq_name.length }.max

          modinfo_validate.modinfo_array.each do |modinfo|
            print Paint[format("%s %-#{max_length}s", "Running validation steps on", modinfo.uniq_name), :cyan, :bright] if verbose > 1

            modinfo.validate

            if modinfo.errors.empty? && modinfo.warnings.empty?
              puts Paint["SUCCESS", :green, :bright] if verbose > 1
              next
            end

            if modinfo.errors.any?
              exit_code = 1
              puts Paint["ERROR", :red, :bright] if verbose? && verbose > 1
              warn modinfo.errors.map { |error| Paint[error, :red] }.join("\n")
              puts "\n" if verbose > 1
            end

            puts Paint["WARNING", :yellow, :bright] if modinfo.warnings.any? && verbose > 1
            puts modinfo.warnings.map { |warning| Paint["#{warning} in #{modinfo.uniq_name}", :yellow] }.join("\n")
            puts "\n" if verbose > 1
          end

          exit exit_code
        end
      end
    end
  end
end
