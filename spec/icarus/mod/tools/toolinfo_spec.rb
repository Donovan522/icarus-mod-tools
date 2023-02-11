require "tools/toolinfo"

RSpec.describe Icarus::Mod::Tools::Toolinfo do
  subject(:toolinfo) { described_class.new(toolinfo_data) }

  let(:toolinfo_data) { JSON.parse(File.read("spec/fixtures/toolinfo.json"), symbolize_names: true)[:tools].first }
  let(:toolinfo_keys) { toolinfo_data.keys }

  describe "#to_h" do
    it "returns a valid baseinfo Hash" do
      expect(described_class::HASHKEYS).to eq(toolinfo_keys)
    end
  end

  describe "#fileType" do
    it "returns a String" do
      expect(toolinfo.fileType).to be_a(String)
    end

    context "when fileType is not set" do
      before { toolinfo_data.delete(:fileType) }

      it "returns a default fileType" do
        expect(toolinfo.fileType).to eq("zip")
      end
    end
  end

  describe "#fileURL" do
    it "exists" do
      expect(toolinfo).to respond_to(:fileURL)
    end

    it "returns a String" do
      expect(toolinfo.fileURL).to be_a(String)
    end

    it "returns correct info" do
      expect(toolinfo.fileURL).to eq(toolinfo_data[:fileURL])
    end
  end

  describe "#valid?" do
    %w[ZIP EXE].each do |filetype|
      context "when fileType is '#{filetype}'" do
        before { toolinfo_data[:fileType] = filetype }

        it { is_expected.to be_valid }
      end
    end
  end
end
