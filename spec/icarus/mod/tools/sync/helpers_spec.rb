require "tools/sync/helpers"
require "uri"
require "json"

RSpec.describe Icarus::Mod::Tools::Sync::Helpers do
  subject(:sync_helpers) { Object.new.extend(described_class) }

  let(:success_response) { instance_double(Net::HTTPSuccess, code: "200", message: "OK", body: modinfo_json) }
  let(:failure_response) { instance_double(Net::HTTPNotFound, code: "404", message: "Not Found") }

  it { is_expected.to respond_to(:retrieve_from_url) }

  describe "#retrieve_from_url" do
    let(:url) { "https://raw.githubusercontent.com/Donovan522/Icarus-Mods/main/modinfo.json" }
    let(:uri) { URI(url) }
    let(:modinfo_json) { File.read("spec/fixtures/modinfo.json") }
    let(:modinfo_array) { JSON.parse(modinfo_json, symbolize_names: true) }

    context "when the URL is valid" do
      before do
        allow(Net::HTTP).to receive(:get_response).with(uri).and_return(success_response)
      end

      it "returns valid JSON data" do
        expect(sync_helpers.retrieve_from_url(uri)).to eq(modinfo_array)
      end
    end

    context "when the URL is invalid" do
      before do
        allow(Net::HTTP).to receive(:get_response).with(uri).and_return(failure_response)
      end

      it "raises an error" do
        expect { sync_helpers.retrieve_from_url(uri) }
          .to raise_error(Icarus::Mod::Tools::Sync::RequestFailed, "HTTP Request failed for #{url} (404): Not Found")
      end
    end
  end
end
