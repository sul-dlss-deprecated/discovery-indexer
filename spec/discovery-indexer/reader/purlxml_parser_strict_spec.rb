require 'spec_helper'

describe DiscoveryIndexer::InputXml::PurlxmlParserStrict do

  before :all do
    @available_purl_xml_ng_doc = Nokogiri::XML(open('spec/fixtures/available_purl_xml_item.xml'), nil, 'UTF-8')
    @identity_metadata = '  <identityMetadata>    <sourceId source="sul">V0401_b1_1.01</sourceId>    <objectId>druid:tn629pk3948</objectId>    <objectCreator>DOR</objectCreator>    <objectLabel>Lecture 1</objectLabel>    <objectType>item</objectType>    <adminPolicy>druid:ww057vk7675</adminPolicy>    <displayType>image</displayType>    <otherId name="label"/>    <otherId name="uuid">08d544da-d459-11e2-8afb-0050569b3c3c</otherId>    <tag>Project:V0401 mccarthyism:vhs</tag>    <tag> Process:Content Type:Media</tag>    <tag> JIRA:DIGREQ-592</tag>    <tag> SMPL:video:ua</tag>    <tag> Registered By:gwillard</tag>    <tag>Remediated By : 4.6.6.2</tag>  </identityMetadata>'
    @rights_metadata = ' <rightsMetadata>   <copyright><human type="copyright">Test copyright statement. All rights reserved unless otherwise indicated.</human></copyright>  <access type="discover">      <machine>        <world/>      </machine>    </access>    <access type="read">      <machine>        <world/>      </machine>    </access>    <use>      <human type="useAndReproduction">Digital recordings from this collection may be accessed freely. These files may not be reproduced or used for any purpose without permission. For permission requests, please contact Stanford University Department of Special Collections  University Archives (speccollref@stanford.edu).</human>    </use>    <use>      <human type="creativeCommons"/>      <machine type="creativeCommons"/>    </use>  </rightsMetadata>'
    @content_metadata = ' <contentMetadata objectId="tn629pk3948" type="media">    <resource sequence="1" id="tn629pk3948_1" type="video">      <label>Tape 1</label>      <file id="tn629pk3948_sl.mp4" mimetype="video/mp4" size="3615267858">                </file>    </resource>    <resource sequence="2" id="tn629pk3948_2" type="image">      <label>Image of media (1 of 3)</label>      <file id="tn629pk3948_img_1.jp2" mimetype="image/jp2" size="919945">        <imageData width="1777" height="2723"/>      </file>    </resource>    <resource sequence="3" id="tn629pk3948_3" type="image">      <label>Image of media (2 of 3)</label>      <file id="tn629pk3948_img_2.jp2" mimetype="image/jp2" size="719940">        <imageData width="2560" height="1475"/>      </file>    </resource>    <resource sequence="4" id="tn629pk3948_4" type="image">      <label>Image of media (3 of 3)</label>      <file id="tn629pk3948_img_3.jp2" mimetype="image/jp2" size="411054">        <imageData width="1547" height="1379"/>      </file>    </resource>  <resource sequence="5" id="tn629pk3948_5" type="page">      <label>Page with Media Information</label>      <file id="tn629pk3948_pg_1.pdf" mimetype="application/pdf" size="411054">
               <imageData width="1547" height="1379"/></file> <file id="tn629pk3948_pg_1.jp2" mimetype="image/jp2" size="411054">        <imageData width="1547" height="1379"/>      </file>    </resource> <resource sequence="6" id="tn629pk3948_6" type="page">      <label>PDF with Media Information</label>      <file id="tn629pk3948_pg_1.pdf" mimetype="application/pdf" size="411054">        <imageData width="1547" height="1379"/>      </file>    </resource></contentMetadata>'
    @blank_content_metadata = ' <contentMetadata objectId="tn629pk3948" type="media">    <resource sequence="1" id="tn629pk3948_1" type="video">      <label>Tape 1</label>    </resource></contentMetadata>'
    @dc = '<oai_dc:dc xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:srw_dc="info:srw/schema/1/dc-schema" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">    <dc:identifier>V0401_b1_1.01</dc:identifier>    <dc:identifier>V0401</dc:identifier>    <dc:title>Lecture 1</dc:title>    <dc:date>2003-01-27</dc:date>    <dc:format>1 tape</dc:format>    <dc:format>VHS</dc:format>    <dc:format>video/mpeg</dc:format>    <dc:type>MovingImage</dc:type>    <dc:contributor>Frantz, Marge (Speaker)</dc:contributor>    <dc:subject>Anti-Communist Movements--United States</dc:subject>    <dc:subject>McCarthy, Joseph, 1908-1957</dc:subject>    <dc:relation type="repository">Stanford University. Libraries. Department of Special Collections and University Archives https://purl.stanford.edu/tn629pk3948</dc:relation>    <dc:rights>Digital recordings from this collection may be accessed freely. These files may not be reproduced or used for any purpose without permission. For permission requests, please contact Stanford University Department of Special Collections  University Archives (speccollref@stanford.edu).     </dc:rights>    <dc:language>eng</dc:language>    <dc:relation type="collection">Marge Frantz lectures on McCarthyism, 2003</dc:relation>  </oai_dc:dc>'
    @rdf = '<rdf:RDF xmlns:fedora="info:fedora/fedora-system:def/relations-external#" xmlns:fedora-model="info:fedora/fedora-system:def/model#" xmlns:hydra="http://projecthydra.org/ns/relations#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">    <rdf:Description rdf:about="info:fedora/druid:tn629pk3948">      <fedora:isMemberOf rdf:resource="info:fedora/druid:yk804rq1656"/>      <fedora:isMemberOfCollection rdf:resource="info:fedora/druid:yk804rq1656"/>    </rdf:Description>  </rdf:RDF>'
  end

  describe '#parse' do
    before(:each) do
      allow(parser).to receive(:parse_content_metadata).and_return(@content_metadata)
      allow(parser).to receive(:parse_identity_metadata)
      allow(parser).to receive(:parse_rights_metadata)
      allow(parser).to receive(:parse_dc)
      allow(parser).to receive(:parse_rdf)
    end
    it 'should call all methods and fill the require fields in the model' do
      allow(parser).to receive(:parse_identity_metadata) { 'identityMetadata' }
      allow(parser).to receive(:parse_rights_metadata) { 'rightsMetadata' }
      allow(parser).to receive(:parse_dc) { 'dc' }
      allow(parser).to receive(:parse_rdf) { 'rdf' }
      allow(parser).to receive(:parse_is_collection) { false }
      allow(parser).to receive(:parse_collection_druids) { ['druid:ab123cd4567'] }
      allow(parser).to receive(:parse_dor_content_type) { 'image' }
      allow(parser).to receive(:parse_dor_display_type) { 'image' }
      allow(parser).to receive(:parse_release_tags_hash) { '' }
      allow(parser).to receive(:parse_file_ids) { ['aa111aa1111_1'] }
      allow(parser).to receive(:parse_image_ids) { ['aa111aa1111_1'] }
      allow(parser).to receive(:parse_catkey) { '123456' }
      allow(parser).to receive(:parse_barcode) { '123456' }
      allow(parser).to receive(:parse_label) { 'label' }
      allow(parser).to receive(:parse_copyright) { 'copyright' }
      allow(parser).to receive(:parse_use_and_reproduction) { 'use_and_reproduction' }
      allow(parser).to receive(:parse_sourceid) { 'sourceid' }

      model = parser.parse
      expect(model.druid).to eq(fake_druid)
      expect(model.public_xml).to be_nil
      expect(model.content_metadata).to eq(@content_metadata)
      expect(model.identity_metadata).to eq('identityMetadata')
      expect(model.rights_metadata).to eq('rightsMetadata')
      expect(model.dc).to eq('dc')
      expect(model.rdf).to eq('rdf')
      expect(model.label).to eq('label')
    end
    it 'collection_druids' do
      allow(parser).to receive(:parse_catkey)
      allow(parser).to receive(:parse_barcode)
      allow(parser).to receive(:parse_label)
      allow(parser).to receive(:parse_copyright)
      allow(parser).to receive(:parse_use_and_reproduction)
      allow(parser).to receive(:parse_sourceid)

      coll_druids = ['ab123cd4567']
      expect(parser).to receive(:parse_collection_druids).and_return(coll_druids)
#      expect(parser).to receive(:parse_predicate_druids).with('isMemberOfCollection', fedora_ns).and_return(coll_druids)
      model = parser.parse
      expect(model.collection_druids).to eq coll_druids
    end
  end

  describe '#parse_identity_metadata' do
    it 'should returnt the identity metadata stream for the valid public xml' do
      im = DiscoveryIndexer::InputXml::PurlxmlParserStrict.new('', @available_purl_xml_ng_doc).send(:parse_identity_metadata)
      expect(im).to be_kind_of(Nokogiri::XML::Document)
      expect(im.root.name).to eql('identityMetadata')
      expect(im.root.xpath('objectId').text).to eql('druid:tn629pk3948')
      expect(im).to be_equivalent_to(Nokogiri::XML(@identity_metadata))
    end

    it "should raise an error when the public xml doesn't have identity metadata" do
      public_xml_no_identity = "<publicObject id='druid:aa111aa1111'>#{@content_metadata}#{@rights_metadata}</publicObject>"
      expect { DiscoveryIndexer::InputXml::PurlxmlParserStrict.new('', public_xml_no_identity).send(:parse_identity_metadata) }.to raise_error(DiscoveryIndexer::Errors::MissingIdentityMetadata)
    end
  end

  describe '#parse_rights_metadata' do
    it 'should returnt the rights metadata stream for the valid public xml' do
      im = DiscoveryIndexer::InputXml::PurlxmlParserStrict.new('', @available_purl_xml_ng_doc).send(:parse_rights_metadata)
      expect(im).to be_kind_of(Nokogiri::XML::Document)
      expect(im.root.name).to eql('rightsMetadata')
      expect(im).to be_equivalent_to(Nokogiri::XML(@rights_metadata))
    end

    it "should raise an error when the public xml doesn't have rights metadata" do
      public_xml_no_rights = "<publicObject id='druid:aa111aa1111'>#{@content_metadata}#{@identity_metadata}</publicObject>"
      expect { DiscoveryIndexer::InputXml::PurlxmlParserStrict.new('', public_xml_no_rights).send(:parse_rights_metadata) }.to raise_error(DiscoveryIndexer::Errors::MissingRightsMetadata)
    end
  end

  describe '#parse_dc' do
    it 'returns the Nokogiri XML Document from dc metadata in purl public xml' do
      im = DiscoveryIndexer::InputXml::PurlxmlParserStrict.new('', @available_purl_xml_ng_doc).send(:parse_dc)
      expect(im).to be_kind_of(Nokogiri::XML::Document)
      expect(im.root.name).to eql('dc')
      expect(im).to be_equivalent_to(Nokogiri::XML(@dc))
    end

    it 'raises an error for the metadata without dc' do
      public_xml_no_dc = "<publicObject id='druid:aa111aa1111'>#{@rights_metadata}#{@identity_metadata}#{@content_metadata}</publicObject>"
      expect { DiscoveryIndexer::InputXml::PurlxmlParserStrict.new('', public_xml_no_dc).send(:parse_dc) }.to raise_error(DiscoveryIndexer::Errors::MissingDC)
    end
  end

  describe '#parse_rdf' do
    it 'should return the rdf for the valid public xml' do
      im = DiscoveryIndexer::InputXml::PurlxmlParserStrict.new('', @available_purl_xml_ng_doc).send(:parse_rdf)
      expect(im).to be_kind_of(Nokogiri::XML::Document)
      expect(im.root.name).to eql('RDF')
      expect(im).to be_equivalent_to(Nokogiri::XML(@rdf))
    end

    it 'should raise an error for the metadata without dc' do
      public_xml_no_dc = "<publicObject id='druid:aa111aa1111'>#{@rights_metadata}#{@identity_metadata}#{@content_metadata}</publicObject>"
      expect { DiscoveryIndexer::InputXml::PurlxmlParserStrict.new('', public_xml_no_dc).send(:parse_rdf) }.to raise_error(DiscoveryIndexer::Errors::MissingRDF)
    end
  end

  describe '#parse_release_tags_hash' do
    it 'parses the release tags from ReleaseData in public XML' do
      release_tags_hash = DiscoveryIndexer::InputXml::PurlxmlParserStrict.new('', @available_purl_xml_ng_doc).send(:parse_release_tags_hash)
      expect(release_tags_hash).to eq('revs_stage' => true, 'sw_prod' => false, 'sw_preview' => false)
    end
    it 'returns empty release tags from pulic XML in the absence of ReleaseData element' do
      reduced_purl_xml_ng = @available_purl_xml_ng_doc.clone
      reduced_purl_xml_ng.search('//ReleaseData').remove
      release_tags_hash = DiscoveryIndexer::InputXml::PurlxmlParserStrict.new('', reduced_purl_xml_ng).send(:parse_release_tags_hash)
      expect(release_tags_hash).to eq({})
    end
    it 'returns empty release tags from nil pulic XML' do
      release_tags_hash = DiscoveryIndexer::InputXml::PurlxmlParserStrict.new('', nil).send(:parse_release_tags_hash)
      expect(release_tags_hash).to eq({})
    end
  end

  describe '#parse_copyright' do
    it 'should parse the copyright statement correctly' do
      copyright = DiscoveryIndexer::InputXml::PurlxmlParserStrict.new('', @available_purl_xml_ng_doc).send(:parse_copyright)
      expect(copyright).to eq('Test copyright statement. All rights reserved unless otherwise indicated.')
    end
  end

  describe '#parse_use_and_reproduction' do
    it 'should parse the use and reproduction statement correctly' do
      use_and_reproduction = DiscoveryIndexer::InputXml::PurlxmlParserStrict.new('', @available_purl_xml_ng_doc).send(:parse_use_and_reproduction)
      expect(use_and_reproduction).to eq('Digital recordings from this collection may be accessed freely. These files may not be reproduced or used for any purpose without permission. For permission requests, please contact Stanford University Department of Special Collections  University Archives (speccollref@stanford.edu).')
    end
  end

  describe '#parse_content_metadata' do
    it 'should return the content metadata stream for the valid public xml' do
      im = DiscoveryIndexer::InputXml::PurlxmlParserStrict.new('', @available_purl_xml_ng_doc).send(:parse_content_metadata)
      expect(im).to be_kind_of(Nokogiri::XML::Document)
      expect(im.root.name).to eql('contentMetadata')
      expect(im).to be_equivalent_to(Nokogiri::XML(@content_metadata))
    end

    it "should return nil when the public xml doesn't have content metadata" do
      public_xml_no_content = "<publicObject id='druid:aa111aa1111'>#{@rights_metadata}#{@identity_metadata}</publicObject>"
      cm = DiscoveryIndexer::InputXml::PurlxmlParserStrict.new('', Nokogiri::XML(public_xml_no_content)).send(:parse_content_metadata)
      expect(cm).to be_nil
    end
  end

  describe 'Parse File and Image IDs' do
    it 'should return nil when no content metadata is present' do
      public_xml_no_content = "<publicObject id='druid:aa111aa1111'>#{@rights_metadata}#{@identity_metadata}</publicObject>"
      pm = DiscoveryIndexer::InputXml::PurlxmlParserStrict.new('', Nokogiri::XML(public_xml_no_content))
      expect(pm.send(:parse_image_ids)).to be_nil
      expect(pm.send(:parse_file_ids)).to be_nil
    end

    it 'should return nil when content metadata is present but no image or page ids are present' do
      public_xml_no_content = "<publicObject id='druid:aa111aa1111'>#{@rights_metadata}#{@identity_metadata}#{@blank_content_metadata}</publicObject>"
      pm = DiscoveryIndexer::InputXml::PurlxmlParserStrict.new('', Nokogiri::XML(public_xml_no_content))
      expect(pm.send(:parse_image_ids)).to be_empty
      expect(pm.send(:parse_file_ids)).to be_nil
    end

    it 'should return image and page ids when present' do
      pm = DiscoveryIndexer::InputXml::PurlxmlParserStrict.new('', @available_purl_xml_ng_doc)
      expect(pm.send(:parse_image_ids)).to eq(['tn629pk3948_img_1.jp2', 'tn629pk3948_img_2.jp2', 'tn629pk3948_img_3.jp2', 'tn629pk3948_pg_1.jp2'])
      expect(pm.send(:parse_file_ids)).to eq(["tn629pk3948_sl.mp4", "tn629pk3948_img_1.jp2", "tn629pk3948_img_2.jp2", "tn629pk3948_img_3.jp2", "tn629pk3948_pg_1.pdf", "tn629pk3948_pg_1.jp2", "tn629pk3948_pg_1.pdf"])
    end
  end

  describe '#parse_catkey' do
    pending
  end

  describe '#parse_barcode' do
    pending
  end

  describe '#parse_label' do
    pending
  end

  describe '#parse_dor_content_type' do
    it 'should return valid dor content type for valid druid' do
      content_type = DiscoveryIndexer::InputXml::PurlxmlParserStrict.new('', @available_purl_xml_ng_doc).send(:parse_dor_content_type)
      expect(content_type).to eq('media')
    end

    it 'should return nil dor content type if there is no content metadata' do
      public_xml_no_content = "<publicObject id='druid:aa111aa1111'>#{@rights_metadata}#{@identity_metadata}</publicObject>"
      content_type = DiscoveryIndexer::InputXml::PurlxmlParserStrict.new('', Nokogiri::XML(public_xml_no_content)).send(:parse_dor_content_type)
      expect(content_type).to be_nil
    end
  end

  describe '#parse_dor_display_type' do
    it 'should return valid dor displayTypeype for valid druid' do
      public_xml_display_type = "<publicObject id='druid:aa111aa1111'>#{@rights_metadata}#{@identity_metadata}#{@content_metadata}</publicObject>"
      display_type = DiscoveryIndexer::InputXml::PurlxmlParserStrict.new('', Nokogiri::XML(public_xml_display_type)).send(:parse_dor_display_type)
      expect(display_type).to eq('image')
    end

    it 'should return nil dor displayType if there is no displayType in the identity metadata' do
      im_no_display_type = '  <identityMetadata>    <sourceId source="sul">V0401_b1_1.01</sourceId>    <objectId>druid:tn629pk3948</objectId>    <objectCreator>DOR</objectCreator>    <objectLabel>Lecture 1</objectLabel>    <objectType>item</objectType>    <adminPolicy>druid:ww057vk7675</adminPolicy>    <otherId name="label"/>    <otherId name="uuid">08d544da-d459-11e2-8afb-0050569b3c3c</otherId>    <tag>Project:V0401 mccarthyism:vhs</tag>    <tag> Process:Content Type:Media</tag>    <tag> JIRA:DIGREQ-592</tag>    <tag> SMPL:video:ua</tag>    <tag> Registered By:gwillard</tag>    <tag>Remediated By : 4.6.6.2</tag>  </identityMetadata>'
      public_xml_no_display_type = "<publicObject id='druid:aa111aa1111'>#{@rights_metadata}#{im_no_display_type}#{@content_metadata}</publicObject>"
      display_type = DiscoveryIndexer::InputXml::PurlxmlParserStrict.new('', Nokogiri::XML(public_xml_no_display_type)).send(:parse_dor_display_type)
      expect(display_type).to be_empty
    end
  end

  describe '#parse_collection_druids' do
    pending
  end

  describe '#parse_is_collection' do
    pending
  end

end
