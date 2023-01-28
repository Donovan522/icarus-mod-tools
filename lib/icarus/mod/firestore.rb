# frozen_string_literal: true

require "google/cloud/firestore"
require "tools/modinfo"
require "tools/proginfo"

module Icarus
  module Mod
    # Helper methods for interacting with the Firestore API
    class Firestore
      attr_reader :client, :collections

      def initialize
        @client = Google::Cloud::Firestore.new(credentials: Config.firebase.credentials.to_h)
        @collections = Config.firebase.collections
      end

      def repos
        @repos ||= list(:repositories)
      end

      def modinfo
        @modinfo ||= list(:modinfo)
      end

      def proginfo
        @proginfo ||= list(:proginfo)
      end

      def mods
        @mods ||= list(:mods)
      end

      def progs
        @progs ||= list(:progs)
      end

      def find_by_type(type:, name:, author:)
        list(type).find { |obj| obj.name == name && obj.author == author }
      end

      def get_list(type)
        raise "Invalid type: #{type} - unknown collection" unless collections.respond_to?(type)

        @client.doc(collections.send(type)).get[:list]
      end

      def list(type)
        case type.to_sym
        when :modinfo, :proginfo, :repositories
          get_list(type)
        when :mods, :progs
          @client.col(collections.send(type)).get.map do |doc|
            klass = type == :mods ? Icarus::Mod::Tools::Modinfo : Icarus::Mod::Tools::Proginfo
            klass.new(doc.data, id: doc.document_id, created: doc.create_time, updated: doc.update_time)
          end
        else
          raise "Invalid type: #{type}"
        end
      end

      def update_or_create(type, payload, merge:)
        doc_id = payload.id || find_by_type(type:, name: payload.name, author: payload.author)&.id

        return @client.doc("#{collections.send(type)}/#{doc_id}").set(payload.to_h, merge:) if doc_id

        @client.col(collections.send(type)).add(payload.to_h)
      end

      def update(type, payload, merge: false)
        raise "You must specify a payload to update" if payload&.empty? || payload.nil?

        case type.to_sym
        when :modinfo, :proginfo
          update_array = (send(type) + [payload]).flatten.uniq
          response = @client.doc(collections.send(type)).set({ list: update_array }, merge:) if update_array.any?
        when :repositories
          response = @client.doc(collections.repositories).set({ list: payload }, merge:)
        when :mod, :prog
          response = update_or_create(pluralize(type), payload, merge:)
        else
          raise "Invalid type: #{type}"
        end

        response.is_a?(Google::Cloud::Firestore::DocumentReference) || response.is_a?(Google::Cloud::Firestore::CommitResponse::WriteResult)
      end

      def delete(type, payload)
        case type.to_sym
        when :mod, :prog
          response = @client.doc("#{collections.send(pluralize(type))}/#{payload.id}").delete
        else
          raise "Invalid type: #{type}"
        end

        response.is_a?(Google::Cloud::Firestore::CommitResponse::WriteResult)
      end

      private

      def pluralize(type)
        type.to_s.end_with?("s") ? type.to_s : "#{type}s"
      end
    end
  end
end
