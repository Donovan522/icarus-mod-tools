# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"
# require "rspec"
require "rspec/core/rake_task"
require "rubocop/rake_task"

# Rake::TestTask.new(:test) do |t|
#   t.libs << "spec"
#   t.libs << "lib"
#   t.test_files = FileList["spec/**/*_spec.rb"]
# end

RuboCop::RakeTask.new
RSpec::Core::RakeTask.new(:spec)

task default: %i[spec rubocop]
