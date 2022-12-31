# frozen_string_literal: true

require "octokit"

module Icarus
  module Mod
    # Helper methods for interacting with the Github API
    class Github
      attr_reader :client

      def initialize
        @client = Octokit::Client.new(access_token: ENV.fetch("GITHUB_TOKEN"))
      end

      def repo
        raise "You must specify a repository to use" unless @repo

        @repo
      end

      def repo=(repo)
        @repo = repo.gsub(%r{https?://.*github\.com/}, "")
      end

      # Recursively returns all files in the repository
      def all_files(path: nil, &block)
        all_files = []

        client.contents(repo, path: path).each do |entry|
          return files(path: entry[:path], &block) if entry[:type] == "dir"

          if block_given?
            block.call entry
          else
            all_files << entry
          end
        end

        return all_files unless block_given?
      end

      def find(name)
        all_files { |file| return file if file[:name] == name }
      end
    end
  end
end
