require 'spec_helper'

describe DiscoveryIndexer::Writer::SolrWriter do
  VCR.configure do |config|
    config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
    config.hook_into :webmock
  end

  describe '.solr_delete_client' do
    before :all do
      @targets_configs = { 'searchworks' => { url: 'http://solr-core:8983/sw-prod/', read_timeout: 120, open_timeout: 120 },
                           'searchworks:preview' => { url: 'http://solr-core:8983/sw-preview/' } }
    end
    it 'should call solr client delete method for each target' do
      solr_writer = DiscoveryIndexer::Writer::SolrWriter.new
      solr_writer.instance_variable_set(:@solr_targets_configs, @targets_configs)

      #   solr_writer.solr_delete_client("aa111aa1111",["searchworks1", "1searchworks:preview"])

      # SolrClient.should_receive(:SolrClient.delete)
      #  expect_any_instance_of(DiscoveryIndexer::Writer::SolrClient).to receive(DiscoveryIndexer::Writer::SolrClient.delete).with("aa111aa1111",nil).and_ret
      # urn
    end
  end

  describe '.get_connector_for_target' do
    it 'should return a connector for a target that is avaliable in config list' do
      solr_writer = DiscoveryIndexer::Writer::SolrWriter.new
      targets_configs = { 'searchworks' => { url: 'http://solr-core:8983/sw-prod/' },
                          'searchworks:preview' => { url: 'http://solr-core:8983/sw-preview/' } }
      solr_writer.instance_variable_set(:@solr_targets_configs, targets_configs)

      solr_connector = solr_writer.get_connector_for_target('searchworks')

      expect(solr_connector.uri.to_s).to eq('http://solr-core:8983/sw-prod/')
    end

    it 'should return a connector for a target that is avaliable in config list' do
      solr_writer = DiscoveryIndexer::Writer::SolrWriter.new
      targets_configs = { 'searchworks' => { url: 'http://solr-core:8983/sw-prod/' },
                          'searchworks:preview' => { url: 'http://solr-core:8983/sw-preview/' } }
      solr_writer.instance_variable_set(:@solr_targets_configs, targets_configs)
      solr_connector = solr_writer.get_connector_for_target('nothing')

      expect(solr_connector).to be_nil
    end

    it 'should return a connector for a target that is avaliable in config list' do
      solr_writer = DiscoveryIndexer::Writer::SolrWriter.new
      targets_configs = { 'searchworks' => { url: 'http://solr-core:8983/sw-prod/', read_timeout: 120, open_timeout: 120 },
                          'searchworks:preview' => { url: 'http://solr-core:8983/sw-preview/' } }
      solr_writer.instance_variable_set(:@solr_targets_configs, targets_configs)

      solr_connector = solr_writer.get_connector_for_target('searchworks')

      expect(solr_connector.options[:url]).to eq('http://solr-core:8983/sw-prod/')
      expect(solr_connector.options[:open_timeout]).to eq(120)
      expect(solr_connector.options[:read_timeout]).to eq(120)
    end
  end
end
