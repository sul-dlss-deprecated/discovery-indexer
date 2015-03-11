require "spec_helper"

describe DiscoveryIndexer::InputXml::Purlxml do
      
  VCR.configure do |config|
    config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
    config.hook_into :webmock 
  end
  
  describe ".load" do
    it "should load mods xml from the purl to the stanford mods model" do
      VCR.use_cassette("available_mods_xml") do
        druid = "tn629pk3948"
        modsxml =  DiscoveryIndexer::InputXml::Modsxml.new(druid)
        modsxml_model =  modsxml.load()
        expect(modsxml_model.sw_full_title).to eq("Lecture 1.")   
      end
    end
    
    
    it "shouldn't re-read public xml from the purl if it is already available" do
      VCR.use_cassette("available_mods_xml") do
        druid = "tn629pk3948"
        modsxml =  DiscoveryIndexer::InputXml::Modsxml.new(druid)
        modsxml_model =  modsxml.load()
        
        modsxml.instance_variable_set(:@druid,"aa111aa1111")
        modsxml_model =  modsxml.load()

        expect(modsxml_model.sw_full_title).to eq("Lecture 1.")   
      end
    end
  end

  describe ".reload" do
    it "should reload the model even if it's loaded  before" do
      druid = "ys174nw6600"
      modsxml =  DiscoveryIndexer::InputXml::Modsxml.new(druid)
       
      VCR.use_cassette("two_available_mods_1_xml") do
        modsxml_model =  modsxml.load()
        expect(modsxml_model.sw_full_title).to eq("Kant's Analysis of the Aesthetic Judgement.")
      end
      
      VCR.use_cassette("two_available_mods_2_xml") do
        modsxml.instance_variable_set(:@druid,"tn629pk3948")
        modsxml_model =  modsxml.reload()

        expect(modsxml_model.sw_full_title).to eq("Lecture 1.")   
      end
    end
  end  
end