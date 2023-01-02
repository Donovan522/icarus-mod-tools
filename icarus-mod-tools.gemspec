# frozen_string_literal: true

require_relative "lib/icarus/mod/version"

Gem::Specification.new do |spec|
  spec.name = "Icarus-Mod-Tools"
  spec.version = Icarus::Mod::VERSION
  spec.authors = ["Donovan Young"]
  spec.email = ["dyoung522@gmail.com"]

  spec.summary = "Various tools for Icarus Modding"
  spec.description = spec.summary
  spec.homepage = "https://github.com/Donovan522/icarus-mod-tools"
  spec.required_ruby_version = ">= 3.1"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/CHANGES.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib", "lib/icarus/mod"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency "google-cloud-firestore", "~> 2.7"
  spec.add_dependency "octokit", "~> 6.0"
  spec.add_dependency "thor", "~> 1.2"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
