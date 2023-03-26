require "tools/modinfo"

RSpec.describe Icarus::Mod::Tools::Modinfo do
  subject(:modinfo) { described_class.new(modinfo_data) }

  let(:modinfo_data) { JSON.parse(File.read("spec/fixtures/modinfo.json"), symbolize_names: true)[:mods].first }
  let(:modinfo_keys) { modinfo_data.keys }
  let(:meta) { {status: {errors: [], warnings: []}} }

  describe "#to_h" do
    it "returns a valid baseinfo Hash" do
      expect(described_class::HASHKEYS | modinfo_keys).to eq(described_class::HASHKEYS)
    end

    it "returns a valid modinfo Hash" do
      expect(modinfo.to_h).to eq(modinfo_data.merge(meta:))
    end
  end

  describe "#file_types" do
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

    context "when file_type is invalid" do
      before { modinfo_data.merge!(files: {foo: "https://example.org/foo"}) }

      it "returns false" do
        expect(modinfo.valid?).to be false
      end

      it "adds to @errors" do
        modinfo.valid?
        expect(modinfo.errors).to include("Invalid fileType: FOO")
      end
    end

    context "when fileType is blank" do
      before { modinfo_data.merge!(files: {}) }

      it "returns false" do
        expect(modinfo.valid?).to be true
      end

      it "adds to @errors" do
        modinfo.valid?
        expect(modinfo.warnings).to eq(["files should not be empty"])
      end
    end

    context "when files URLs are invalid" do
      before { modinfo_data.merge!(files: {pak: "invalid"}) }

      it "returns false" do
        expect(modinfo.valid?).to be false
      end

      it "adds to @errors" do
        modinfo.valid?
        expect(modinfo.errors).to include("Invalid URL: invalid")
      end
    end
  end
end
