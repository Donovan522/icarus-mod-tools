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

  describe "#uniq_name" do
    it "returns a String with author and name" do
      expect(modinfo.uniq_name).to eq("#{modinfo.author}/#{modinfo.name}")
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

  describe "#validate" do
    context "when given valid Modinfo data" do
      it "returns true" do
        expect(modinfo.validate).to be true
      end

      it "does not add to @errors" do
        modinfo.validate
        expect(modinfo.errors).to be_empty
      end

      it "does not add to warnings" do
        modinfo.validate
        expect(modinfo.warnings).to be_empty
      end
    end

    context "when fileType is blank" do
      before { modinfo.read(modinfo_data.merge(fileType: "")) }

      it "returns false" do
        expect(modinfo.validate).to be false
      end

      it "adds to @errors" do
        modinfo.validate
        expect(modinfo.errors).to include("Invalid fileType: ")
      end
    end

    context "when fileType is invalid" do
      before { modinfo.read(modinfo_data.merge(fileType: "FOO")) }

      it "returns false" do
        expect(modinfo.validate).to be false
      end

      it "adds to @errors" do
        modinfo.validate
        expect(modinfo.errors).to include("Invalid fileType: FOO")
      end
    end

    context "when version is blank" do
      before { modinfo.read(modinfo_data.merge(version: "")) }

      it "returns true" do
        expect(modinfo.validate).to be true
      end

      it "does not add to @errors" do
        modinfo.validate
        expect(modinfo.errors).to be_empty
      end

      it "adds to @warnings" do
        modinfo.validate
        expect(modinfo.warnings).to eq(["Version should be a version string"])
      end
    end

    context "when version is invalid" do
      before { modinfo.read(modinfo_data.merge(version: "FOO")) }

      it "returns false" do
        expect(modinfo.validate).to be true
      end

      it "adds to @warnings" do
        modinfo.validate
        expect(modinfo.warnings).to eq(["Version should be a version string"])
      end
    end

    %w[name author description].each do |key|
      context "when #{key} is blank" do
        before { modinfo.read(modinfo_data.merge(key.to_sym => "")) }

        it "returns false" do
          expect(modinfo.validate).to be false
        end

        it "adds to @errors" do
          modinfo.validate
          expect(modinfo.errors).to include("#{key.capitalize} cannot be blank")
        end
      end
    end

    %w[fileURL imageURL readmeURL].each do |key|
      context "when #{key} URL is invalid" do
        before { modinfo.read(modinfo_data.merge(key.to_sym => "invalid")) }

        it "returns false" do
          expect(modinfo.validate).to be false
        end

        it "adds to @errors" do
          modinfo.validate
          expect(modinfo.errors).to include("Invalid URL #{key.capitalize}: invalid")
        end
      end
    end
  end
end
