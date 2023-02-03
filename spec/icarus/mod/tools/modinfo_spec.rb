require "tools/modinfo"

RSpec.describe Icarus::Mod::Tools::Modinfo do
  subject(:modinfo) { described_class.new(modinfo_data) }

  let(:modinfo_data) { JSON.parse(File.read("spec/fixtures/modinfo.json"), symbolize_names: true)[:mods].first }
  let(:modinfo_keys) { modinfo_data.keys }

  describe "#to_h" do
    it "returns a valid baseinfo Hash" do
      expect(described_class::HASHKEYS | modinfo_keys).to eq(described_class::HASHKEYS)
    end

    it "returns a valid modinfo Hash" do
      expect(modinfo.to_h).to eq(modinfo_data)
    end

    context "when using the old format" do
      subject(:modinfo) { described_class.new(deprecated_modinfo_data) }

      let(:deprecated_modinfo_data) { JSON.parse(File.read("spec/fixtures/modinfo_old.json"), symbolize_names: true)[:mods].first }

      it "returns a valid modinfo Hash" do
        expect(modinfo.to_h).to eq(deprecated_modinfo_data)
      end
    end
  end

  describe "#fileType" do
    context "when fileType is not set" do
      before { modinfo_data.delete(:fileType) }

      it "returns a default fileType" do
        expect(modinfo.fileType).to eq("pak")
      end
    end
  end

  describe "#file_types" do
    context "when files is not set" do
      before { modinfo_data.delete(:files) }

      it "returns a default fileType" do
        expect(modinfo.file_types).to eq(["pak"])
      end
    end

    context "when files is set" do
      it "returns all file_types" do
        expect(modinfo.file_types).to eq(%i[pak exmodz zip])
      end
    end
  end

  describe "#valid?" do
    %w[ZIP PAK EXMOD EXMODZ].each do |filetype|
      context "when fileType is '#{filetype}'" do
        before { modinfo_data[:fileType] = filetype }

        it { is_expected.to be_valid }
      end
    end
  end
end
