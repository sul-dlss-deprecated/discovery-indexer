require 'spec_helper'

describe DiscoveryIndexer::Mapper::GeneralMapper do
  VCR.configure do |config|
    config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
    config.hook_into :webmock
  end

  describe '.convert_to_solr_doc' do
    it 'should map mods and public xml into solr doc' do
      druid = 'tn629pk3948'

      purl_model = nil
      VCR.use_cassette('available_purl_xml') do
        purl_model =  DiscoveryIndexer::InputXml::Purlxml.new(druid).load
      end

      mods_model = nil
      VCR.use_cassette('available_mods_xml') do
        mods_model =  DiscoveryIndexer::InputXml::Modsxml.new(druid).load
      end

      mapper = DiscoveryIndexer::Mapper::GeneralMapper.new(druid, mods_model, purl_model)
      solr_doc = mapper.convert_to_solr_doc
      expect(solr_doc[:id]).to eq('tn629pk3948')
      expect(solr_doc[:title]).to eq('Lecture 1.')
    end
  end
end
