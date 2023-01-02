# frozen_string_literal: true

require "google/cloud/firestore"
require "tools/modinfo"

module Icarus
  module Mod
    # Helper methods for interacting with the Firestore API
    class Firestore
      attr_reader :client

      COLLECTIONS = {
        modinfo: "meta/modinfo",
        repositories: "meta/repos",
        mods: "mods"
      }.freeze

      def initialize
        @client = Google::Cloud::Firestore.new(project_id: "projectdaedalus-fb09f", credentials: ENV.fetch("GOOGLE_APPLICATION_CREDENTIALS", nil))
      end

      def repos
        @repos ||= list(:repositories)
      end

      def modinfo_array
        @modinfo_array ||= list(:modinfo)
      end

      def mods
        @mods ||= list(:mods)
      end

      def find_mod(field, value)
        mods.find { |mod| mod.send(field) == value }
      end

      def list(type)
        case type
        when :modinfo
          @client.doc(COLLECTIONS[:modinfo]).get[:list]
        when :repositories
          @client.doc(COLLECTIONS[:repositories]).get[:list]
        when :mods
          @client.col(COLLECTIONS[:mods]).get.map do |doc|
            Icarus::Mod::Tools::Modinfo.new(doc.data, id: doc.document_id, created: doc.create_time, updated: doc.update_time)
          end
        else
          raise "Invalid type: #{type}"
        end
      end

      def update_or_create_mod(payload, merge:)
        doc_id = payload.id || find_mod(:name, payload.name)&.id

        return @client.doc("#{COLLECTIONS[:mods]}/#{doc_id}").set(payload.to_h, merge:) if doc_id

        @client.col(COLLECTIONS[:mods]).add(payload.to_h)
      end

      def update(type, payload, merge: false)
        raise "You must specify a payload to update" if payload&.empty? || payload.nil?

        case type
        when :modinfo
          response = @client.doc(COLLECTIONS[:modinfo]).set({ list: payload }, merge:)
        when :repositories
          response = @client.doc(COLLECTIONS[:repositories]).set({ list: payload }, merge:)
        when :mod
          response = update_or_create_mod(payload, merge:)
        else
          raise "Invalid type: #{type}"
        end

        response.is_a?(Google::Cloud::Firestore::DocumentReference) || response.is_a?(Google::Cloud::Firestore::CommitResponse::WriteResult)
      end

      def delete(type, payload)
        case type
        when :mod
          response = @client.doc("#{COLLECTIONS[:mods]}/#{payload.id}").delete
        else
          raise "Invalid type: #{type}"
        end

        response.is_a?(Google::Cloud::Firestore::CommitResponse::WriteResult)
      end
    end
  end
end
