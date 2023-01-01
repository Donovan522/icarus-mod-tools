# frozen_string_literal: true

require "google/cloud/firestore"

module Icarus
  module Mod
    # Helper methods for interacting with the Firestore API
    class Firestore
      attr_reader :client

      def initialize
        @client = Google::Cloud::Firestore.new(project_id: "projectdaedalus-fb09f", credentials: ENV.fetch("FIREBASE_KEYFILE"))
      end

      def repos
        @repos ||= list(:repositories)
      end

      def list(type)
        case type
        when :modinfo
          @client.doc("meta/modinfo").get[:list]
        when :repositories
          @client.doc("meta/repos").get[:list]
        else
          raise "Invalid type: #{type}"
        end
      end

      def update(type, payload, merge: false)
        raise "You must specify a payload to update" if payload&.empty? || payload.nil?

        case type
        when :modinfo
          resp = @client.doc("meta/modinfo").set({ list: payload }, merge: merge)
        when :repositories
          resp = @client.doc("meta/repos").set({ list: payload }, merge: merge)
        else
          raise "Invalid type: #{type}"
        end

        raise "Failed to update #{type}" unless resp.respond_to?(:update_time)

        (Time.now - resp.update_time) < 60
      end
    end
  end
end
