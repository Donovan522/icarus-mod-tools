# frozen_string_literal: true

module Icarus
  module Mod
    module Tools
      # Sync methods
      class Modinfo
        attr_reader :data, :id, :created_at, :updated_at

        HASHKEYS = %i[name author version compatibility description fileType fileURL].freeze

        def initialize(data, id: nil, created: nil, updated: nil)
          @id = id
          @created_at = created
          @updated_at = updated
          read(data)
        end

        def read(data)
          @data = data.is_a?(String) ? JSON.parse(data, symbolize_names: true) : data
        end

        def to_json(*args)
          JSON.generate(@data, *args)
        end

        def to_h
          @data || {}
        end

        def to_s
          format(
            "%-<name>30s %-<author>20s v%-<version>10s %<description>s",
            name:, author:, version: (version || "None"), description:
          )
        end

        def method_missing(method_name, *_args, &)
          to_h[method_name.to_sym].strip
        end

        def respond_to_missing?(method_name, include_private = false)
          @data&.key?(method_name.to_sym) || super
        end
      end
    end
  end
end
