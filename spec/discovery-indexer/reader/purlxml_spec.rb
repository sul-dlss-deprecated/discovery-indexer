require 'spec_helper'

describe DiscoveryIndexer::InputXml::Purlxml do
  before :each do
    @available_purl_xml_ng_doc = Nokogiri::XML(open('spec/fixtures/available_purl_xml_item.xml'), nil, 'UTF-8')
    @identity_metadata = '  <identityMetadata>    <sourceId source="sul">V0401_b1_1.01</sourceId>    <objectId>druid:tn629pk3948</objectId>    <objectCreator>DOR</objectCreator>    <objectLabel>Lecture 1</objectLabel>    <objectType>item</objectType>    <adminPolicy>druid:ww057vk7675</adminPolicy>    <otherId name="label"/>    <otherId name="uuid">08d544da-d459-11e2-8afb-0050569b3c3c</otherId>    <tag>Project:V0401 mccarthyism:vhs</tag>    <tag> Process:Content Type:Media</tag>    <tag> JIRA:DIGREQ-592</tag>    <tag> SMPL:video:ua</tag>    <tag> Registered By:gwillard</tag>    <tag>Remediated By : 4.6.6.2</tag>  </identityMetadata>'
    @rights_metadata = ' <rightsMetadata>    <access type="discover">      <machine>        <world/>      </machine>    </access>    <access type="read">      <machine>        <world/>      </machine>    </access>    <use>      <human type="useAndReproduction">Digital recordings from this collection may be accessed freely. These files may not be reproduced or used for any purpose without permission. For permission requests, please contact Stanford University Department of Special Collections  University Archives (speccollref@stanford.edu).</human>    </use>    <use>      <human type="creativeCommons"/>      <machine type="creativeCommons"/>    </use>  </rightsMetadata>'
    @content_metadata = ' <contentMetadata objectId="tn629pk3948" type="media">    <resource sequence="1" id="tn629pk3948_1" type="video">      <label>Tape 1</label>      <file id="tn629pk3948_sl.mp4" mimetype="video/mp4" size="3615267858">                </file>    </resource>    <resource sequence="2" id="tn629pk3948_2" type="image">      <label>Image of media (1 of 3)</label>      <file id="tn629pk3948_img_1.jp2" mimetype="image/jp2" size="919945">        <imageData width="1777" height="2723"/>      </file>    </resource>    <resource sequence="3" id="tn629pk3948_3" type="image">      <label>Image of media (2 of 3)</label>      <file id="tn629pk3948_img_2.jp2" mimetype="image/jp2" size="719940">        <imageData width="2560" height="1475"/>      </file>    </resource>    <resource sequence="4" id="tn629pk3948_4" type="image">      <label>Image of media (3 of 3)</label>      <file id="tn629pk3948_img_3.jp2" mimetype="image/jp2" size="411054">        <imageData width="1547" height="1379"/>      </file>    </resource>  </contentMetadata>'
    @dc = '<oai_dc:dc xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:srw_dc="info:srw/schema/1/dc-schema" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">    <dc:identifier>V0401_b1_1.01</dc:identifier>    <dc:identifier>V0401</dc:identifier>    <dc:title>Lecture 1</dc:title>    <dc:date>2003-01-27</dc:date>    <dc:format>1 tape</dc:format>    <dc:format>VHS</dc:format>    <dc:format>video/mpeg</dc:format>    <dc:type>MovingImage</dc:type>    <dc:contributor>Frantz, Marge (Speaker)</dc:contributor>    <dc:subject>Anti-Communist Movements--United States</dc:subject>    <dc:subject>McCarthy, Joseph, 1908-1957</dc:subject>    <dc:relation type="repository">Stanford University. Libraries. Department of Special Collections and University Archives https://purl.stanford.edu/tn629pk3948</dc:relation>    <dc:rights>Digital recordings from this collection may be accessed freely. These files may not be reproduced or used for any purpose without permission. For permission requests, please contact Stanford University Department of Special Collections  University Archives (speccollref@stanford.edu).     </dc:rights>    <dc:language>eng</dc:language>    <dc:relation type="collection">Marge Frantz lectures on McCarthyism, 2003</dc:relation>  </oai_dc:dc>'
    @rdf = '<rdf:RDF xmlns:fedora="info:fedora/fedora-system:def/relations-external#" xmlns:fedora-model="info:fedora/fedora-system:def/model#" xmlns:hydra="http://projecthydra.org/ns/relations#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">    <rdf:Description rdf:about="info:fedora/druid:tn629pk3948">      <fedora:isMemberOf rdf:resource="info:fedora/druid:yk804rq1656"/>      <fedora:isMemberOfCollection rdf:resource="info:fedora/druid:yk804rq1656"/>    </rdf:Description>  </rdf:RDF>'
  end

  describe '.load' do
    it 'should load public xml from the purl to the model' do
      VCR.use_cassette('available_purl_xml') do
        druid = 'tn629pk3948'
        p = DiscoveryIndexer::InputXml::Purlxml.new(druid)
        model = p.load

        expect(model.content_metadata).to be_equivalent_to(@content_metadata)
        expect(model.identity_metadata).to be_equivalent_to(@identity_metadata)
        expect(model.rights_metadata).to be_equivalent_to(@rights_metadata)
        expect(model.rdf).to be_equivalent_to(@rdf)
        expect(model.dc).to be_equivalent_to(@dc)
      end
    end

    it "shouldn't re-read public xml from the purl if it is already available" do
      VCR.use_cassette('available_purl_xml') do
        druid = 'tn629pk3948'
        p = DiscoveryIndexer::InputXml::Purlxml.new(druid)
        model = p.load

        p.instance_variable_set(:@druid, 'aa111aa1111')
        model = p.load

        expect(model.content_metadata).to be_equivalent_to(@content_metadata)
        expect(model.identity_metadata).to be_equivalent_to(@identity_metadata)
        expect(model.rights_metadata).to be_equivalent_to(@rights_metadata)
        expect(model.rdf).to be_equivalent_to(@rdf)
        expect(model.dc).to be_equivalent_to(@dc)
      end
    end
  end
end
