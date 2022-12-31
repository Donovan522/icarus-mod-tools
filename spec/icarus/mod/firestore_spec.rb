RSpec.describe Icarus::Mod::Firestore do
  context "when initialized" do
    subject { described_class.new }

    it { is_expected.to be_a(described_class) }
    it { is_expected.to respond_to(:client) }
    it { is_expected.to respond_to(:repos) }

    describe "#client" do
      subject { super().client }

      it { is_expected.to be_a(Google::Cloud::Firestore::Client) }
    end
  end
end
