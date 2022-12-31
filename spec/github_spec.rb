RSpec.describe Icarus::Mod::Github do
  context "when initialized" do
    subject { described_class.new }

    it { is_expected.to be_a(described_class) }
    it { is_expected.to respond_to(:client) }
    it { is_expected.to respond_to(:repo) }
    it { is_expected.to respond_to(:repo=) }
    it { is_expected.to respond_to(:all_files) }
    it { is_expected.to respond_to(:find) }

    describe "#client" do
      subject { super().client }

      it { is_expected.to be_a(Octokit::Client) }
    end
  end
end
