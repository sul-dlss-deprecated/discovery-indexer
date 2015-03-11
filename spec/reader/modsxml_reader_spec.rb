require "spec_helper"

describe DiscoveryIndexer::InputXml::ModsxmlReader do 
  
  VCR.configure do |config|
    config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
    config.hook_into :webmock 
  end

  describe ".read" do
    it "should read mods xml for an available druid" do
      VCR.use_cassette("available_mods_xml") do
        druid = "tn629pk3948"
        modsxml_ng_doc = DiscoveryIndexer::InputXml::ModsxmlReader.read(druid)
        expect(modsxml_ng_doc.root.name).to eq("mods")  
      end
    end
    
    it "should raise an exception if the mods page is not available" do
      VCR.use_cassette("not_available_mods_xml") do
        druid = "xx111xxx1111"
        expect{DiscoveryIndexer::InputXml::ModsxmlReader.read(druid)}.to raise_error(DiscoveryIndexer::Errors::MissingModsPage)
      end
    end
    
    it "should raise an error if the druid is empty or nil" do
      VCR.use_cassette("empty_druid_mods_xml") do
        druid = ""
        expect{DiscoveryIndexer::InputXml::ModsxmlReader.read(druid)}.to raise_error(DiscoveryIndexer::Errors::MissingModsPage)
      end
      
      VCR.use_cassette("nil_druid_mods_xml") do
         druid = nil
         expect{DiscoveryIndexer::InputXml::ModsxmlReader.read(druid)}.to raise_error(DiscoveryIndexer::Errors::MissingModsPage)
       end
    end
  end
end

