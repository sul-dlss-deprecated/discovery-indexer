require 'spec_helper'

describe DiscoveryIndexer::InputXml::PurlxmlReader do
  describe '.read' do
    it 'should read public xml for an available druid' do
      available_expected_response = File.open('spec/fixtures/available_purl_xml_item_2.xml').read

      VCR.use_cassette('available_purl_xml_2') do
        druid = 'bg210vm0680'
        actual_response = DiscoveryIndexer::InputXml::PurlxmlReader.read(druid)
        expect(actual_response).to be_equivalent_to(Nokogiri::XML(available_expected_response, nil, 'UTF-8'))
      end
    end

    it 'should raise an exception if the purl page is not available' do
      VCR.use_cassette('not_available_purl_xml') do
        druid = 'xx111xxx1111'
        expect { DiscoveryIndexer::InputXml::PurlxmlReader.read(druid) }.to raise_error(DiscoveryIndexer::Errors::MissingPurlPage)
      end
    end

    it 'should raise an error if the druid is empty or nil' do
      VCR.use_cassette('empty_druid_purl_xml') do
        druid = ''
        expect { DiscoveryIndexer::InputXml::PurlxmlReader.read(druid) }.to raise_error(DiscoveryIndexer::Errors::MissingPurlPage)
      end

      VCR.use_cassette('nil_druid_purl_xml') do
        druid = nil
        expect { DiscoveryIndexer::InputXml::PurlxmlReader.read(druid) }.to raise_error(DiscoveryIndexer::Errors::MissingPurlPage)
      end
    end
  end
end
