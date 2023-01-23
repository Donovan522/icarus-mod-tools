require "tools/modinfo"

RSpec.describe Icarus::Mod::Tools::Modinfo do
  subject(:modinfo) { described_class.new(modinfo_data) }

  let(:modinfo_data) { JSON.parse(File.read("spec/fixtures/modinfo.json"), symbolize_names: true) }
  let(:modinfo_keys) { modinfo_data[:mods].first.keys }

  describe "#to_h" do
    it "returns a valid baseinfo Hash" do
      expect(described_class::HASHKEYS).to eq(modinfo_keys)
    end
  end

  describe "#fileType" do
    context "when fileType is not set" do
      before { modinfo_data[:mods].first.delete(:fileType) }

      it "returns a default fileType" do
        expect(modinfo.fileType).to eq("pak")
      end
    end
  end
end
