# frozen_string_literal: true

require "firestore"
require "github"
require "tools/modinfo_sync"

RSpec.describe Icarus::Mod::Tools::ModinfoSync do
  subject(:modinfo_sync) { described_class.new }

  let(:firestore_double) { instance_double(Icarus::Mod::Firestore) }
  let(:github_double) { instance_double(Icarus::Mod::Github) }
  let(:url) { "https://github.com/author/mod" }
  let(:modinfo_url) { "https://raw.githubusercontent.com/author/mod/master/modinfo.json" }
  let(:raw_modinfo) { File.read("spec/fixtures/modinfo.json") }
  let(:modinfo) { Icarus::Mod::Tools::Modinfo.new(raw_modinfo) }
  let(:modinfo_array) { [modinfo] }

  before do
    allow(firestore_double).to receive(:repos).and_return([url])
    allow(firestore_double).to receive(:update).and_return(true)
    allow(Icarus::Mod::Firestore).to receive(:new).and_return(firestore_double)

    allow(github_double).to receive(:find).and_return(modinfo_url)
    allow(github_double).to receive(:repository=).and_return(true)
    allow(Icarus::Mod::Github).to receive(:new).and_return(github_double)

    # rubocop:disable RSpec/SubjectStub - we're stubbing the helper method which is tested elsewhere
    allow(modinfo_sync).to receive(:retrieve_from_url).with(url).and_return(
      JSON.parse(File.read("spec/fixtures/modinfo_array.json"), symbolize_names: true)
    )
    # rubocop:enable RSpec/SubjectStub
  end

  describe "#repositories" do
    it "calls Firestore.repos" do
      modinfo_sync.repositories

      expect(firestore_double).to have_received(:repos)
    end
  end

  describe "#update" do
    it "calls Firestore.update" do
      modinfo_sync.update(modinfo_array)

      expect(firestore_double).to have_received(:update).with(:modinfo, modinfo_array)
    end
  end

  describe "#modinfo" do
    it "returns a modinfo JSON array" do
      expect(modinfo_sync.modinfo(url)).to eq(JSON.parse(File.read("spec/fixtures/modinfo_array.json"), symbolize_names: true))
    end
  end

  describe "#modinfo_data" do
    context "when the repository is on Github" do
      it "returns an array of modinfo urls" do
        expect(modinfo_sync.modinfo_data([url])).to eq([modinfo_url])
      end
    end

    context "when the repository is not on Github" do
      let(:url) { "https://gitlab.com/author/mod" }

      it "returns an empty array" do
        expect(modinfo_sync.modinfo_data([url])).to eq([])
      end
    end
  end
end
