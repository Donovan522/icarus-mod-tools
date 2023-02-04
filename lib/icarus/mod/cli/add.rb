# frozen_string_literal: true

require "firestore"
require "tools/modinfo"

module Icarus
  module Mod
    module CLI
      # Sync CLI command definitions
      class Add < SubcommandBase
        desc "modinfo", "Adds an entry to 'meta/modinfo/list'"
        def modinfo(item)
          firestore = Firestore.new
          payload = [firestore.modinfo, item].flatten.compact

          puts firestore.update(:modinfo, payload, merge: true) ? "Success" : "Failure"
        end

        desc "toolinfo", "Adds an entry to 'meta/toolinfo/list'"
        def toolinfo(item)
          firestore = Firestore.new
          payload = [firestore.toolinfo, item].flatten.compact

          puts firestore.update(:toolinfo, payload, merge: true) ? "Success" : "Failure"
        end

        desc "repos", "Adds an entry to 'meta/repos/list'"
        def repos(item)
          firestore = Firestore.new
          payload = [firestore.repositories, item].flatten.compact

          puts firestore.update(:repositories, payload, merge: true) ? "Success" : "Failure"
        end

        desc "mod", "Adds an entry to 'mods'"
        method_option :modinfo, type: :string, required: true, default: "modinfo.json", desc: "Path to the modinfo.json file"
        def mod
          firestore = Firestore.new
          data = options[:modinfo]

          if data.nil? || !File.exist?(data)
            warn "Invalid data file: #{data}"
            exit 1
          end

          JSON.parse(File.read(data), symbolize_names: true)[:mods].each do |mod|
            modinfo = Icarus::Mod::Tools::Modinfo.new(mod)

            unless modinfo.valid?
              warn "Invalid modinfo: #{modinfo.errors}"
              exit 1
            end

            puts firestore.update(:mod, modinfo, merge: true) ? "Success" : "Failure"
          end
        end
      end
    end
  end
end
