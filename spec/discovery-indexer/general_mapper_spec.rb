require 'spec_helper'

describe DiscoveryIndexer::GeneralMapper do
  let(:fake_druid) { 'oo000oo0000' }
  let(:mapper) { described_class.new(fake_druid) }
  let(:fedora_ns) { DiscoveryIndexer::InputXml::PurlxmlParserStrict::FEDORA_NAMESPACE }

  context '#convert_to_solr_doc' do
    let(:smods_rec) { Stanford::Mods::Record.new }
    let(:mods) do
      <<-EOF
        <mods xmlns="#{Mods::MODS_NS}">
          <titleInfo>
            <title>Lecture 1.</title>
          </titleInfo>
        </mods>
        EOF
    end
    it 'maps mods and public xml into solr doc' do
      allow(mapper).to receive(:modsxml).and_return(smods_rec.from_str(mods))
      solr_doc = mapper.convert_to_solr_doc
      expect(solr_doc[:id]).to eq(fake_druid)
      expect(solr_doc[:title]).to eq('Lecture 1.')
    end
  end

  context '#blank_titles' do
    let(:smods_rec) { Stanford::Mods::Record.new }
    it 'gets nil for the title if the title cannot be found in the mods' do
      mods=<<-EOF
        <mods xmlns="#{Mods::MODS_NS}">
          <titleInfo>
            <title></title>
          </titleInfo>
        </mods>
        EOF
      allow(mapper).to receive(:modsxml).and_return(smods_rec.from_str(mods))
      solr_doc = mapper.convert_to_solr_doc
      expect(solr_doc[:id]).to eq(fake_druid)
      expect(solr_doc[:title]).to eq(nil)
    end
  end
  
  context '#collection_druids' do
    it 'calls purlxml.collection_druids' do
      purlxml = double('purlxml')
      expect(purlxml).to receive(:collection_druids)
      expect(mapper).to receive(:purlxml).and_return(purlxml)
      mapper.collection_druids
    end
    it 'Array of bare collection druids from rels-ext in public xml' do
      public_xml_ng =
        Nokogiri::XML <<-EOF
          <publicObject id='druid:#{fake_druid}'>
            <identityMetadata />
            <rightsMetadata />
            <oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" />
            <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:fedora="#{fedora_ns}">
              <rdf:Description rdf:about="info:fedora/druid:#{fake_druid}">
                <fedora:isMemberOf rdf:resource="info:fedora/druid:xh235dd9059"/>
                <fedora:isMemberOfCollection rdf:resource="info:fedora/druid:xh235dd9059"/>
                <fedora:isMemberOfCollection rdf:resource="info:fedora/druid:aa097bm8879"/>
              </rdf:Description>
            </rdf:RDF>
          </publicObject>
          EOF
      parser = DiscoveryIndexer::InputXml::PurlxmlParserStrict.new(fake_druid, public_xml_ng)
      allow(mapper).to receive(:purlxml).and_return(parser.parse)
      expect(mapper.collection_druids).to eq ['xh235dd9059', 'aa097bm8879']
    end
    it 'empty Array if there are no collection druids' do
      public_xml_ng =
        Nokogiri::XML <<-EOF
          <publicObject id='druid:#{fake_druid}'>
            <identityMetadata />
            <rightsMetadata />
            <oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" />
            <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:fedora="#{fedora_ns}">
              <rdf:Description rdf:about="info:fedora/druid:#{fake_druid}">
                <fedora:isConstituentOf rdf:resource="info:fedora/druid:hj097bm8879"/>
                <fedora:isEmpty/>
              </rdf:Description>
            </rdf:RDF>
          </publicObject>
          EOF
      parser = DiscoveryIndexer::InputXml::PurlxmlParserStrict.new(fake_druid, public_xml_ng)
      allow(mapper).to receive(:purlxml).and_return(parser.parse)
      expect(mapper.collection_druids).to eq []
    end
  end

  context '#collection_data' do
    it 'creates DiscoveryIndexer::Collection for each coll druid' do
      allow(mapper).to receive(:collection_druids).and_return(['1', '2', '3'])
      expect(DiscoveryIndexer::Collection).to receive(:new).exactly(3).times
      mapper.collection_data
    end
    it 'Array of DiscoveryIndexer::Collection objects for each collection druid from rels-ext in public xml' do
      public_xml_ng =
        Nokogiri::XML <<-EOF
          <publicObject id='druid:#{fake_druid}'>
            <identityMetadata />
            <rightsMetadata />
            <oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" />
            <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:fedora="#{DiscoveryIndexer::InputXml::PurlxmlParserStrict::FEDORA_NAMESPACE}">
              <rdf:Description rdf:about="info:fedora/druid:#{fake_druid}">
                <fedora:isMemberOf rdf:resource="info:fedora/druid:xh235dd9059"/>
                <fedora:isMemberOfCollection rdf:resource="info:fedora/druid:xh235dd9059"/>
                <fedora:isMemberOfCollection rdf:resource="info:fedora/druid:aa097bm8879"/>
                <fedora:isConstituentOf rdf:resource="info:fedora/druid:hj097bm8879"/>
                <fedora:isEmpty/>
              </rdf:Description>
            </rdf:RDF>
          </publicObject>
          EOF
      parser = DiscoveryIndexer::InputXml::PurlxmlParserStrict.new(fake_druid, public_xml_ng)
      allow(mapper).to receive(:purlxml).and_return(parser.parse)
      coll_data = mapper.collection_data
      expect(coll_data.size).to eq 2
      expect(coll_data[0]).to be_an_instance_of(DiscoveryIndexer::Collection)
      expect(coll_data[0].druid).to eq 'xh235dd9059'
      expect(coll_data[1]).to be_an_instance_of(DiscoveryIndexer::Collection)
      expect(coll_data[1].druid).to eq 'aa097bm8879'
    end
    it 'empty Array when there are no collection druids' do
      public_xml_ng =
        Nokogiri::XML <<-EOF
          <publicObject id='druid:#{fake_druid}'>
            <identityMetadata />
            <rightsMetadata />
            <oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" />
            <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:fedora="#{fedora_ns}">
              <rdf:Description rdf:about="info:fedora/druid:#{fake_druid}">
                <fedora:isConstituentOf rdf:resource="info:fedora/druid:hj097bm8879"/>
                <fedora:isEmpty/>
              </rdf:Description>
            </rdf:RDF>
          </publicObject>
          EOF
      parser = DiscoveryIndexer::InputXml::PurlxmlParserStrict.new(fake_druid, public_xml_ng)
      allow(mapper).to receive(:purlxml).and_return(parser.parse)
      expect(mapper.collection_data).to eq []
    end
  end

  context '#constituent_druids' do
    it 'calls purlxml.constituent_druids' do
      purlxml = double('purlxml')
      expect(purlxml).to receive(:constituent_druids)
      expect(mapper).to receive(:purlxml).and_return(purlxml)
      mapper.constituent_druids
    end
    it 'Array of bare constituent druids from rels-ext in public xml' do
      public_xml_ng =
        Nokogiri::XML <<-EOF
          <publicObject id='druid:#{fake_druid}'>
            <identityMetadata />
            <rightsMetadata />
            <oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" />
            <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:fedora="#{fedora_ns}">
              <rdf:Description rdf:about="info:fedora/druid:#{fake_druid}">
                <fedora:isMemberOf rdf:resource="info:fedora/druid:xh235dd9059"/>
                <fedora:isMemberOfCollection rdf:resource="info:fedora/druid:xh235dd9059"/>
                <fedora:isConstituentOf rdf:resource="info:fedora/druid:hj097bm8879"/>
                <fedora:isConstituentOf rdf:resource="info:fedora/druid:aa097bm8879"/>
              </rdf:Description>
            </rdf:RDF>
          </publicObject>
          EOF
      parser = DiscoveryIndexer::InputXml::PurlxmlParserStrict.new(fake_druid, public_xml_ng)
      allow(mapper).to receive(:purlxml).and_return(parser.parse)
      expect(mapper.constituent_druids).to eq ['hj097bm8879', 'aa097bm8879']
    end
    it 'empty Array if there are no constituent druids' do
      public_xml_ng =
        Nokogiri::XML <<-EOF
          <publicObject id='druid:#{fake_druid}'>
            <identityMetadata />
            <rightsMetadata />
            <oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" />
            <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:fedora="#{fedora_ns}">
              <rdf:Description rdf:about="info:fedora/druid:#{fake_druid}">
                <fedora:isMemberOf rdf:resource="info:fedora/druid:xh235dd9059"/>
                <fedora:isMemberOfCollection rdf:resource="info:fedora/druid:xh235dd9059"/>
              </rdf:Description>
            </rdf:RDF>
          </publicObject>
          EOF
      parser = DiscoveryIndexer::InputXml::PurlxmlParserStrict.new(fake_druid, public_xml_ng)
      allow(mapper).to receive(:purlxml).and_return(parser.parse)
      expect(mapper.constituent_druids).to eq []
    end
  end

  context '#constituent_data' do
    it 'creates DiscoveryIndexer::Collection for each constituent druid' do
      allow(mapper).to receive(:constituent_druids).and_return(['1', '2', '3'])
      expect(DiscoveryIndexer::Collection).to receive(:new).exactly(3).times
      mapper.constituent_data
    end
    it 'Array of DiscoveryIndexer::Collection objects for each constituent druid from rels-ext in public xml' do
      public_xml_ng =
        Nokogiri::XML <<-EOF
          <publicObject id='druid:#{fake_druid}'>
            <identityMetadata />
            <rightsMetadata />
            <oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" />
            <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:fedora="#{DiscoveryIndexer::InputXml::PurlxmlParserStrict::FEDORA_NAMESPACE}">
              <rdf:Description rdf:about="info:fedora/druid:#{fake_druid}">
                <fedora:isMemberOf rdf:resource="info:fedora/druid:xh235dd9059"/>
                <fedora:isMemberOfCollection rdf:resource="info:fedora/druid:xh235dd9059"/>
                <fedora:isConstituentOf rdf:resource="info:fedora/druid:hj097bm8879"/>
                <fedora:isConstituentOf rdf:resource="info:fedora/druid:aa097bm8879"/>
                <fedora:isEmpty/>
              </rdf:Description>
            </rdf:RDF>
          </publicObject>
          EOF
      parser = DiscoveryIndexer::InputXml::PurlxmlParserStrict.new(fake_druid, public_xml_ng)
      allow(mapper).to receive(:purlxml).and_return(parser.parse)
      const_data = mapper.constituent_data
      expect(const_data.size).to eq 2
      expect(const_data[0]).to be_an_instance_of(DiscoveryIndexer::Collection)
      expect(const_data[0].druid).to eq 'hj097bm8879'
      expect(const_data[1]).to be_an_instance_of(DiscoveryIndexer::Collection)
      expect(const_data[1].druid).to eq 'aa097bm8879'
    end
    it 'empty Array when there are no constituent druids' do
      public_xml_ng =
        Nokogiri::XML <<-EOF
          <publicObject id='druid:#{fake_druid}'>
            <identityMetadata />
            <rightsMetadata />
            <oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" />
            <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:fedora="#{fedora_ns}">
              <rdf:Description rdf:about="info:fedora/druid:#{fake_druid}">
                <fedora:isMemberOf rdf:resource="info:fedora/druid:xh235dd9059"/>
                <fedora:isMemberOfCollection rdf:resource="info:fedora/druid:xh235dd9059"/>
              </rdf:Description>
            </rdf:RDF>
          </publicObject>
          EOF
      parser = DiscoveryIndexer::InputXml::PurlxmlParserStrict.new(fake_druid, public_xml_ng)
      allow(mapper).to receive(:purlxml).and_return(parser.parse)
      expect(mapper.constituent_data).to eq []
    end
  end
end
