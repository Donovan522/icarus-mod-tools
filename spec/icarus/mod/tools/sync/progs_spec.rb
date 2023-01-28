# frozen_string_literal: true

require "firestore"
require "tools/sync/progs"

RSpec.describe Icarus::Mod::Tools::Sync::Progs do
  subject(:progsync) { described_class.new }

  let(:firestore_double) { instance_double(Icarus::Mod::Firestore) }
  let(:url) { "https://raw.githubusercontent.com/author/mod/master/proginfo.json" }
  let(:proginfo_data) { JSON.parse(File.read("spec/fixtures/proginfo.json"), symbolize_names: true) }
  let(:proginfo) { Icarus::Mod::Tools::Proginfo.new(proginfo_data[:programs].first) }

  before do
    allow(firestore_double).to receive(:progs).and_return([])
    allow(firestore_double).to receive(:find_by_type).and_return(proginfo)
    allow(firestore_double).to receive(:update).and_return(true)
    allow(firestore_double).to receive(:delete).and_return(true)
    allow(Icarus::Mod::Firestore).to receive(:new).and_return(firestore_double)

    progsync.instance_variable_set(:@info_array, [proginfo])
  end

  describe "#progs" do
    it "calls Firestore.progs" do
      progsync.progs

      expect(firestore_double).to have_received(:progs)
    end
  end

  describe "#info_array" do
    it "returns an array of Proginfo objects" do
      expect(progsync.info_array).to all(be_a(Icarus::Mod::Tools::Proginfo))
    end
  end

  describe "#find" do
    it "calls Firestore.find_by_type with :prog" do
      progsync.find(proginfo)

      expect(firestore_double).to have_received(:find_by_type).with(type: "progs", name: "Test Icarus Modding Tool", author: "Test User")
    end
  end

  describe "#find_info" do
    it "returns a Proginfo object" do
      expect(progsync.find_info(proginfo)).to be_a(Icarus::Mod::Tools::Proginfo)
    end
  end

  describe "#update" do
    it "calls Firestore.update" do
      progsync.update(proginfo)

      expect(firestore_double).to have_received(:update).with(:prog, proginfo, merge: false)
    end
  end

  describe "#delete" do
    it "calls Firestore.delete" do
      progsync.delete(proginfo)

      expect(firestore_double).to have_received(:delete).with(:prog, proginfo)
    end
  end
end
