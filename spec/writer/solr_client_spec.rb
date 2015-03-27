require "spec_helper"

describe DiscoveryIndexer::Writer::SolrClient do
      
  VCR.configure do |config|
    config.allow_http_connections_when_no_cassette = true
    config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
    config.hook_into :webmock 
  end
  
  describe ".add" do
    it "should add an item to the solr index" do
      druid = "tn629pk3948"
      
      purl_model=nil
      VCR.use_cassette("available_purl_xml") do
        purl_model =  DiscoveryIndexer::InputXml::Purlxml.new(druid).load()
      end
      
      mods_model = nil
      VCR.use_cassette("available_mods_xml") do
        mods_model =  DiscoveryIndexer::InputXml::Modsxml.new(druid).load()
      end
      
      mapper = DiscoveryIndexer::Mapper::GeneralMapper.new(druid, mods_model, purl_model)
      solr_doc =  mapper.map 
      
      solr_connector = nil
      VCR.use_cassette('rsolr_client_config_call') do  
        solr_connector = RSolr.connect 'http://localhost:8983/solr/'
      end
      VCR.use_cassette('rsolr_client_index') do  
        expect{DiscoveryIndexer::Writer::SolrClient.add(druid, solr_doc, solr_connector)}.not_to raise_error
      end
    end
    

  end
  
  describe ".process" do
    it "should update an item that exists in solr index" do
      solr_connector = nil
      VCR.use_cassette('rsolr_client_config_call') do  
        solr_connector = RSolr.connect :url=>'http://localhost:8983/solr/', :allow_update=> true
      end
      VCR.use_cassette('rsolr_update') do
        DiscoveryIndexer::Writer::SolrClient.process("dw077vs7846",{:id=>"dw077vs7846",:title_display=>"New title"},solr_connector,1)
      end
    end
  end
  
  
  describe ".delete" do
    it "should delete an item from solr index" do      
      solr_connector = nil
      VCR.use_cassette('rsolr_client_config_call') do  
        solr_connector = RSolr.connect 'http://localhost:8983/solr/'
      end
      VCR.use_cassette('rsolr_client_delete') do  
        expect{DiscoveryIndexer::Writer::SolrClient.delete("tn629pk3948",{}, solr_connector)}.not_to raise_error
      end 
    end
  end
end