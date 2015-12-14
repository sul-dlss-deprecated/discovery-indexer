require 'spec_helper'

describe DiscoveryIndexer::GeneralMapper do
  describe '.convert_to_solr_doc' do
    let(:fake_druid) { 'tn629pk3948' }
    let(:smods_rec) { Stanford::Mods::Record.new }
    let(:public_xml) do
      Nokogiri::XML <<-EOF
        <publicObject id="druid:tn629pk3948" published="2014-08-09T11:20:13-07:00">
          <identityMetadata>
            <sourceId source="sul">V0401_b1_1.01</sourceId>
            <objectId>druid:tn629pk3948</objectId>
            <objectCreator>DOR</objectCreator>
            <objectLabel>Lecture 1</objectLabel>
            <objectType>item</objectType>
            <displayType>image</displayType>
            <adminPolicy>druid:ww057vk7675</adminPolicy>
            <otherId name="label"/>
            <otherId name="uuid">08d544da-d459-11e2-8afb-0050569b3c3c</otherId>
            <tag>Project:V0401 mccarthyism:vhs</tag>
            <tag> Process:Content Type:Media</tag>
            <tag> JIRA:DIGREQ-592</tag>
            <tag> SMPL:video:ua</tag>
            <tag> Registered By:gwillard</tag>
            <tag>Remediated By : 4.6.6.2</tag>
          </identityMetadata>
        </publicObject>
        EOF
    end
    let(:mods) do
      <<-EOF
        <mods xmlns="#{Mods::MODS_NS}">
          <titleInfo>
            <title>Lecture 1.</title>
          </titleInfo>
        </mods>
        EOF
    end
    let(:mapper) do
      DiscoveryIndexer::GeneralMapper.new(fake_druid)
    end
    it 'should map mods and public xml into solr doc' do
      allow(mapper).to receive(:modsxml).and_return(smods_rec.from_str(mods))
      solr_doc = mapper.convert_to_solr_doc
      expect(solr_doc[:id]).to eq('tn629pk3948')
      expect(solr_doc[:title]).to eq('Lecture 1.')
    end
  end
end
