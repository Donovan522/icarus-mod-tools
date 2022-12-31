# frozen_string_literal: true

require "test_helper"

class Icarus::Mod::Database::TestSync < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Icarus::Mod::Database::Sync::VERSION
  end

  def test_it_does_something_useful
    skip
    assert false
  end
end
