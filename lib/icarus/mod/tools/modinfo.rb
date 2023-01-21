# frozen_string_literal: true

module Icarus
  module Mod
    module Tools
      # Sync methods
      class Modinfo
        attr_reader :data, :errors, :id, :created_at, :updated_at, :warnings

        HASHKEYS = %i[name author version compatibility description long_description fileType fileURL imageURL readmeURL].freeze

        def initialize(data, id: nil, created: nil, updated: nil)
          @id = id
          @created_at = created
          @updated_at = updated
          @errors = []
          @warnings = []

          read(data)
        end

        def read(data)
          @data = data.is_a?(String) ? JSON.parse(data, symbolize_names: true) : data
        end

        def uniq_name
          "#{author}/#{name}"
        end

        # rubocop:disable Naming/MethodName
        def fileType
          @data[:fileType] || "pak"
        end
        # rubocop:enable Naming/MethodName

        def to_json(*args)
          JSON.generate(@data, *args)
        end

        def to_h
          {
            name:,
            author:,
            version:,
            compatibility:,
            description:,
            long_description:,
            fileType:,
            fileURL:,
            imageURL:,
            readmeURL:
          }
        end

        def validate
          @warnings << "Version should be a version string" unless validate_version(version)

          %w[name author description].each do |key|
            @errors << "#{key.capitalize} cannot be blank" unless validate_string(@data[key.to_sym])
          end

          @errors << "Invalid fileType: #{fileType || "blank"}" unless validate_filetype(fileType)

          %w[fileURL imageURL readmeURL].each do |key|
            @errors << "Invalid URL #{key.capitalize}: #{@data[key.to_sym] || "blank"}" unless validate_url(@data[key.to_sym])
          end

          @errors.empty?
        end

        def method_missing(method_name, *_args, &)
          @data[method_name.to_sym]&.strip
        end

        def respond_to_missing?(method_name, include_private = false)
          HASHKEYS.include?(method_name.to_sym) || super
        end

        private

        def validate_url(url)
          return true if url.nil? || url.empty?

          url =~ URI::DEFAULT_PARSER.make_regexp
        end

        def validate_filetype(filetype)
          %w[pak zip exmod].include?(filetype.downcase)
        end

        def validate_string(string)
          !(string.nil? || string.empty?)
        end

        def validate_version(version)
          version =~ /\d+\.\d+[.\d+]?/
        end
      end
    end
  end
end
