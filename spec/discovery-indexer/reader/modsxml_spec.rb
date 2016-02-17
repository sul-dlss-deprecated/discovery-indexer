require 'spec_helper'

describe DiscoveryIndexer::InputXml::Purlxml do
  describe '.load' do
    it 'loads mods xml from purl page to the stanford mods model' do
      VCR.use_cassette('available_mods_xml') do
        druid = 'tn629pk3948'
        modsxml = DiscoveryIndexer::InputXml::Modsxml.new(druid)
        modsxml_model = modsxml.load
        expect(modsxml_model.sw_full_title).to eq('Lecture 1.')
      end
    end

    it "doesn't re-read public xml from the purl if it is already available" do
      VCR.use_cassette('available_mods_xml') do
        druid = 'tn629pk3948'
        modsxml = DiscoveryIndexer::InputXml::Modsxml.new(druid)
        modsxml.load

        modsxml.instance_variable_set(:@druid, 'aa111aa1111')
        modsxml_model = modsxml.load

        expect(modsxml_model.sw_full_title).to eq('Lecture 1.')
      end
    end
  end
end
