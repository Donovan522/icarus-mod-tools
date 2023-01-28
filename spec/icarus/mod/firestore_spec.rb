require "firestore"

RSpec.describe Icarus::Mod::Firestore do
  context "when initialized" do
    subject { described_class.new }

    before do
      allow(Google::Cloud::Firestore).to receive(:new).and_return(instance_double(Google::Cloud::Firestore::Client))
      allow(Icarus::Mod::Config).to receive(:firebase).and_return(
        OpenStruct.new(
          credentials: OpenStruct.new(to_h: {}),
          collections: OpenStruct.new(modinfo: "test-modinfo", repositories: "test-repositories", mods: "test-mods")
        )
      )
    end

    it { is_expected.to be_a(described_class) }
    it { is_expected.to respond_to(:client) }
    it { is_expected.to respond_to(:repos) }
    it { is_expected.to respond_to(:mods) }
    it { is_expected.to respond_to(:tools) }
  end
end
