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
        @repos ||= firestore.doc("meta/repos").get[:list]
      end
    end
  end
end
