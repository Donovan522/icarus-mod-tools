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
        @repos ||= @client.doc("meta/repos").get[:list]
      end

      def update_modinfo_list(modinfo_array)
        @client.doc("meta/modinfo").set({ list: modinfo_array })
      end
    end
  end
end
