require "tools/modinfo"

RSpec.describe Icarus::Mod::Tools::Modinfo do
  subject(:modinfo) { described_class.new(modinfo_array.first) }

  let(:modinfo_array) { JSON.parse(File.read("spec/fixtures/modinfo_array.json"), symbolize_names: true)[:mods] }
  let(:modinfo_data) { modinfo_array.first }

  describe "#read" do
    context "when given a Hash" do
      it "returns a Modinfo Hash" do
        expect(modinfo.read(modinfo_data)&.keys).to eq(described_class::HASHKEYS)
      end
    end

    context "when given a String" do
      it "returns a Modinfo Hash" do
        expect(modinfo.read(modinfo_data.to_json)&.keys).to eq(described_class::HASHKEYS)
      end
    end
  end

  describe "#to_json" do
    it "returns a JSON String" do
      expect(modinfo.to_json).to be_a(String)
    end

    it "returns a valid JSON String" do
      expect(modinfo.to_json).to eql(JSON.generate(JSON.parse(File.read("spec/fixtures/modinfo.json"))))
    end
  end

  describe "#to_h" do
    it "returns a Hash" do
      expect(modinfo.to_h).to be_a(Hash)
    end

    it "returns a valid Modinfo Hash" do
      expect(modinfo.to_h.keys).to eq(described_class::HASHKEYS)
    end
  end

  describe "Data accessors" do
    described_class::HASHKEYS.each do |key|
      it { is_expected.to respond_to(key) }
    end
  end
end
