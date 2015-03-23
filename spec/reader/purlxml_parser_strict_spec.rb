require "spec_helper"

describe DiscoveryIndexer::InputXml::PurlxmlParserStrict do 
  
  before :all do
    @available_purl_xml_ng_doc = Nokogiri::XML(open('spec/fixtures/available_purl_xml_item.xml'),nil,'UTF-8')
    @identity_metadata = '  <identityMetadata>    <sourceId source="sul">V0401_b1_1.01</sourceId>    <objectId>druid:tn629pk3948</objectId>    <objectCreator>DOR</objectCreator>    <objectLabel>Lecture 1</objectLabel>    <objectType>item</objectType>    <adminPolicy>druid:ww057vk7675</adminPolicy>    <otherId name="label"/>    <otherId name="uuid">08d544da-d459-11e2-8afb-0050569b3c3c</otherId>    <tag>Project:V0401 mccarthyism:vhs</tag>    <tag> Process:Content Type:Media</tag>    <tag> JIRA:DIGREQ-592</tag>    <tag> SMPL:video:ua</tag>    <tag> Registered By:gwillard</tag>    <tag>Remediated By : 4.6.6.2</tag>  </identityMetadata>'
    @rights_metadata = ' <rightsMetadata>    <access type="discover">      <machine>        <world/>      </machine>    </access>    <access type="read">      <machine>        <world/>      </machine>    </access>    <use>      <human type="useAndReproduction">Digital recordings from this collection may be accessed freely. These files may not be reproduced or used for any purpose without permission. For permission requests, please contact Stanford University Department of Special Collections  University Archives (speccollref@stanford.edu).</human>    </use>    <use>      <human type="creativeCommons"/>      <machine type="creativeCommons"/>    </use>  </rightsMetadata>'
    @content_metadata = ' <contentMetadata objectId="tn629pk3948" type="media">    <resource sequence="1" id="tn629pk3948_1" type="video">      <label>Tape 1</label>      <file id="tn629pk3948_sl.mp4" mimetype="video/mp4" size="3615267858">                </file>    </resource>    <resource sequence="2" id="tn629pk3948_2" type="image">      <label>Image of media (1 of 3)</label>      <file id="tn629pk3948_img_1.jp2" mimetype="image/jp2" size="919945">        <imageData width="1777" height="2723"/>      </file>    </resource>    <resource sequence="3" id="tn629pk3948_3" type="image">      <label>Image of media (2 of 3)</label>      <file id="tn629pk3948_img_2.jp2" mimetype="image/jp2" size="719940">        <imageData width="2560" height="1475"/>      </file>    </resource>    <resource sequence="4" id="tn629pk3948_4" type="image">      <label>Image of media (3 of 3)</label>      <file id="tn629pk3948_img_3.jp2" mimetype="image/jp2" size="411054">        <imageData width="1547" height="1379"/>      </file>    </resource>  </contentMetadata>'
    @dc = '<oai_dc:dc xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:srw_dc="info:srw/schema/1/dc-schema" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">    <dc:identifier>V0401_b1_1.01</dc:identifier>    <dc:identifier>V0401</dc:identifier>    <dc:title>Lecture 1</dc:title>    <dc:date>2003-01-27</dc:date>    <dc:format>1 tape</dc:format>    <dc:format>VHS</dc:format>    <dc:format>video/mpeg</dc:format>    <dc:type>MovingImage</dc:type>    <dc:contributor>Frantz, Marge (Speaker)</dc:contributor>    <dc:subject>Anti-Communist Movements--United States</dc:subject>    <dc:subject>McCarthy, Joseph, 1908-1957</dc:subject>    <dc:relation type="repository">Stanford University. Libraries. Department of Special Collections and University Archives http://purl.stanford.edu/tn629pk3948</dc:relation>    <dc:rights>Digital recordings from this collection may be accessed freely. These files may not be reproduced or used for any purpose without permission. For permission requests, please contact Stanford University Department of Special Collections  University Archives (speccollref@stanford.edu).     </dc:rights>    <dc:language>eng</dc:language>    <dc:relation type="collection">Marge Frantz lectures on McCarthyism, 2003</dc:relation>  </oai_dc:dc>'
    @rdf = '<rdf:RDF xmlns:fedora="info:fedora/fedora-system:def/relations-external#" xmlns:fedora-model="info:fedora/fedora-system:def/model#" xmlns:hydra="http://projecthydra.org/ns/relations#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">    <rdf:Description rdf:about="info:fedora/druid:tn629pk3948">      <fedora:isMemberOf rdf:resource="info:fedora/druid:yk804rq1656"/>      <fedora:isMemberOfCollection rdf:resource="info:fedora/druid:yk804rq1656"/>    </rdf:Description>  </rdf:RDF>'
  end
  
  describe ".parse" do
    it "should call all methods and fill the require fields in the model" do
      parser = DiscoveryIndexer::InputXml::PurlxmlParserStrict.new(nil)
      allow(parser).to receive(:parse_content_metadata) { "contentMetadata" }
      allow(parser).to receive(:parse_identity_metadata) { "identityMetadata" }
      allow(parser).to receive(:parse_rights_metadata) { "rightsMetadata" }
      allow(parser).to receive(:parse_dc) { "dc" }
      allow(parser).to receive(:parse_rdf) { "rdf" }
      allow(parser).to receive(:parse_is_collection) { false }
      allow(parser).to receive(:parse_collection_druids) { ["druid:ab123cd4567"]}
      allow(parser).to receive(:parse_dor_content_type) { "image" }
      allow(parser).to receive(:parse_release_tags_hash) { "" }
      allow(parser).to receive(:parse_file_ids) { ["aa111aa1111_1"] }
      allow(parser).to receive(:parse_image_ids) { ["aa111aa1111_1"] }
      allow(parser).to receive(:parse_catkey) { "123456" }
      allow(parser).to receive(:parse_barcode) { "123456" }
      allow(parser).to receive(:parse_label) { "label" }

      model = parser.parse()
      expect(model.public_xml).to be_nil
      expect(model.content_metadata).to eq("contentMetadata")
      expect(model.identity_metadata).to eq("identityMetadata")
      expect(model.rights_metadata).to eq("rightsMetadata")
      expect(model.dc).to eq("dc")
      expect(model.rdf).to eq("rdf")
      expect(model.label).to eq("label")
      
    end
  end

  describe ".parse_identity_metadata" do
    it "should returnt the identity metadata stream for the valid public xml" do
      im = DiscoveryIndexer::InputXml::PurlxmlParserStrict.new(@available_purl_xml_ng_doc).parse_identity_metadata()
      expect(im).to be_kind_of(Nokogiri::XML::Document)
      expect(im.root.name).to eql('identityMetadata')
      expect(im.root.xpath('objectId').text).to eql("druid:tn629pk3948")
      expect(im).to be_equivalent_to(Nokogiri::XML(@identity_metadata)) 
    end
    
    it "should raise an error when the public xml doesn't have identity metadata" do
      public_xml_no_identity = "<publicObject id='druid:aa111aa1111'>#{@content_metadata}#{@rights_metadata}</publicObject>"
      expect{DiscoveryIndexer::InputXml::PurlxmlParserStrict.new(public_xml_no_identity).parse_identity_metadata()}.to raise_error(DiscoveryIndexer::Errors::MissingIdentityMetadata)
    end
  end

  describe ".parse_rights_metadata" do
    it "should returnt the rights metadata stream for the valid public xml" do
      im = DiscoveryIndexer::InputXml::PurlxmlParserStrict.new(@available_purl_xml_ng_doc).parse_rights_metadata()
      expect(im).to be_kind_of(Nokogiri::XML::Document)
      expect(im.root.name).to eql('rightsMetadata')
      expect(im).to be_equivalent_to(Nokogiri::XML(@rights_metadata)) 
    end
    
    it "should raise an error when the public xml doesn't have rights metadata" do
      public_xml_no_rights = "<publicObject id='druid:aa111aa1111'>#{@content_metadata}#{@identity_metadata}</publicObject>"
      expect{DiscoveryIndexer::InputXml::PurlxmlParserStrict.new(public_xml_no_rights).parse_rights_metadata()}.to raise_error(DiscoveryIndexer::Errors::MissingRightsMetadata)
    end    
  end
  
  describe ".parse_dc" do
    it "should returnt the dc metadata stream for the valid public xml" do
      im = DiscoveryIndexer::InputXml::PurlxmlParserStrict.new(@available_purl_xml_ng_doc).parse_dc()
      expect(im).to be_kind_of(Nokogiri::XML::Document)
      expect(im.root.name).to eql('dc')
      expect(im).to be_equivalent_to(Nokogiri::XML(@dc)) 
    end
    
    it "should raise an error for the metadata without dc" do
      public_xml_no_dc = "<publicObject id='druid:aa111aa1111'>#{@rights_metadata}#{@identity_metadata}#{@content_metadata}</publicObject>"
      expect{DiscoveryIndexer::InputXml::PurlxmlParserStrict.new(public_xml_no_dc).parse_dc()}.to raise_error(DiscoveryIndexer::Errors::MissingDC)
    end
  end
  
  describe ".parse_rdf" do
    it "should returnt the rdf for the valid public xml" do
      im = DiscoveryIndexer::InputXml::PurlxmlParserStrict.new(@available_purl_xml_ng_doc).parse_rdf()
      expect(im).to be_kind_of(Nokogiri::XML::Document)
      expect(im.root.name).to eql('RDF')
      expect(im).to be_equivalent_to(Nokogiri::XML(@rdf)) 
    end
    
    it "should raise an error for the metadata without dc" do
      public_xml_no_dc = "<publicObject id='druid:aa111aa1111'>#{@rights_metadata}#{@identity_metadata}#{@content_metadata}</publicObject>"
      expect{DiscoveryIndexer::InputXml::PurlxmlParserStrict.new(public_xml_no_dc).parse_rdf()}.to raise_error(DiscoveryIndexer::Errors::MissingRDF)
    end
  end
  
  describe ".parse_release_tags_hash" do
    pending
  end
  
  describe ".parse_content_metadata" do
    it "should returnt the content metadata stream for the valid public xml" do
      im = DiscoveryIndexer::InputXml::PurlxmlParserStrict.new(@available_purl_xml_ng_doc).parse_content_metadata()
      expect(im).to be_kind_of(Nokogiri::XML::Document)
      expect(im.root.name).to eql('contentMetadata')
      expect(im).to be_equivalent_to(Nokogiri::XML(@content_metadata)) 
    end
    
    it "should return nil when the public xml doesn't have content metadata" do
      public_xml_no_content = "<publicObject id='druid:aa111aa1111'>#{@rights_metadata}#{@identity_metadata}</publicObject>"
      cm = DiscoveryIndexer::InputXml::PurlxmlParserStrict.new(Nokogiri::XML(public_xml_no_content)).parse_content_metadata()
      expect(cm).to be_nil
    end    
  end
  
  describe ".parse_file_ids" do
    pending
  end
  
  describe ".parse_image_ids" do
    pending
  end
  
  describe ".parse_catkey" do
    pending
  end
  
  describe ".parse_barcode" do
    pending
  end
  
  describe ".parse_label" do
    pending
  end
  
  describe ".parse_dor_content_type" do
   pending 
  end
  
  describe ".parse_collection_druids" do
    pending
  end
  
  describe ".parse_is_collection" do
    pending
  end
end