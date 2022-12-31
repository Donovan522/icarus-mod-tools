# frozen_string_literal: true

RSpec.describe Icarus::Mod::Database::Sync::VERSION do
  it { is_expected.not_to be_nil }
  it { is_expected.to match(/\d+\.\d+\.\d+/) }
end
