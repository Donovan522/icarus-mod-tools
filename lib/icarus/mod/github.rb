# frozen_string_literal: true

require "octokit"

module Icarus
  module Mod
    # Helper methods for interacting with the Github API
    class Github
      attr_reader :client, :resources

      def initialize(repo = nil)
        self.repository = repo if repo
        @client = Octokit::Client.new(access_token: ENV.fetch("GITHUB_TOKEN"))
        @resources = []
      end

      def repository
        raise "You must specify a repository to use" unless @repository

        @repository
      end

      def repository=(repo)
        @resources = [] # reset the resources cache
        @repository = repo.gsub(%r{https?://.*github\.com/}, "")
      end

      # Recursively returns all resources in the repository
      def all_files(path: nil, cache: true, &block)
        # If we've already been called for this repository, use the cached resources
        use_cache = @resources.any? && cache

        if use_cache
          @resources.each { |file| block.call(file) } if block_given?
        else
          @client.contents(repository, path: path).each do |entry|
            if entry[:type] == "dir"
              all_files(path: entry[:path], cache: false, &block)
              next # skip directories
            end

            block.call(entry) if block_given?
            @resources << entry # cache the file
          end
        end

        @resources unless block_given?
      end

      def find(pattern)
        all_files { |file| return file if file[:name] =~ /#{pattern}/i }
      end
    end
  end
end
