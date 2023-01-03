# frozen_string_literal: true

require "firestore"
require "tools/mod_sync"

RSpec.describe Icarus::Mod::Tools::ModSync do
  subject(:modsync) { described_class.new }

  let(:firestore_double) { instance_double(Icarus::Mod::Firestore) }
  let(:url) { "https://raw.githubusercontent.com/author/mod/master/modinfo.json" }
  let(:modinfo) { Icarus::Mod::Tools::Modinfo.new(File.read("spec/fixtures/modinfo.json")) }
  let(:modinfo_array) { [modinfo] }

  before do
    allow(firestore_double).to receive(:mods).and_return([])
    allow(firestore_double).to receive(:modinfo_array).and_return([url])
    allow(firestore_double).to receive(:find_mod).and_return(modinfo)
    allow(firestore_double).to receive(:update).and_return(true)
    allow(firestore_double).to receive(:delete).and_return(true)
    allow(Icarus::Mod::Firestore).to receive(:new).and_return(firestore_double)
    # rubocop:disable RSpec/SubjectStub - we're stubbing the helper method which is tested elsewhere
    allow(modsync).to receive(:retrieve_from_url).with(url).and_return(
      JSON.parse(File.read("spec/fixtures/modinfo_array.json"), symbolize_names: true)
    )
    # rubocop:enable RSpec/SubjectStub
    modsync.instance_variable_set(:@modinfo_array, modinfo_array)
  end

  describe "#mods" do
    it "calls Firestore.mods" do
      modsync.mods

      expect(firestore_double).to have_received(:mods)
    end
  end

  describe "#modinfo_array" do
    it "returns an array of Modinfo objects" do
      expect(modsync.modinfo_array).to all(be_a(Icarus::Mod::Tools::Modinfo))
    end
  end

  describe "#find_mod" do
    it "calls Firestore.find_mod" do
      modsync.find_mod(modinfo)

      expect(firestore_double).to have_received(:find_mod).with(name: "Test Icarus Mod", author: "Test User")
    end
  end

  describe "#find_modinfo" do
    it "returns a Modinfo object" do
      expect(modsync.find_modinfo(modinfo)).to be_a(Icarus::Mod::Tools::Modinfo)
    end
  end

  describe "#update" do
    it "calls Firestore.update" do
      modsync.update(modinfo)

      expect(firestore_double).to have_received(:update).with(:mod, modinfo, merge: false)
    end
  end

  describe "#delete" do
    it "calls Firestore.delete" do
      modsync.delete(modinfo)

      expect(firestore_double).to have_received(:delete).with(:mod, modinfo)
    end
  end
end
