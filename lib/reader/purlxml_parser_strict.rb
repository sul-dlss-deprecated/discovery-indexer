module DiscoveryIndexer
  module InputXml
    class PurlxmlParserStrict < PurlxmlParser
      
      RDF_NAMESPACE = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'
      OAI_DC_NAMESPACE = 'http://www.openarchives.org/OAI/2.0/oai_dc/'
      MODS_NAMESPACE = 'http://www.loc.gov/mods/v3'
      def initialize(purlxml_ng_doc)
        super
      end
      
      
      # it parses the purlxml into a purlxml model
      # @return [PurlxmlModel] represents the purlxml as parsed based on the parser rules
      def parse()
        purlxml_model = PurlxmlModel.new
        purlxml_model.public_xml = @purlxml_ng_doc
        purlxml_model.identity_metadata = parse_identity_metadata()
        purlxml_model.rights_metadata = parse_rights_metadata()
        purlxml_model.dc = parse_dc()
        purlxml_model.rdf = parse_rdf()
        purlxml_model.release_tags_hash = parse_release_tags_hash()
        
        begin
          purlxml_model.content_metadata = parse_content_metadata()
        rescue
          #We need to make a collection check
        end
        
        return purlxml_model
      end
      
      # extracts the identityMetadata for this fedora object, from the purl xml
      # @return [Nokogiri::XML::Document] the identityMetadata for the fedora object
      # @raise [DiscoveryIndexer::Errors::MissingIdentityMetadata] if there is no contentMetadata
      def parse_identity_metadata
        begin
          ng_doc = Nokogiri::XML(@purlxml_ng_doc.root.xpath('/publicObject/identityMetadata').to_xml)
          raise DiscoveryIndexer::Errors::MissingIdentityMetadata.new(@purlxml_ng_doc.inspect) if !ng_doc || ng_doc.children.empty?
          ng_doc 
        rescue
          raise DiscoveryIndexer::Errors::MissingIdentityMetadata.new(@purlxml_ng_doc.inspect)
        end
      end
      
      def parse_rights_metadata 
        begin
          ng_doc = Nokogiri::XML(@purlxml_ng_doc.root.xpath('/publicObject/rightsMetadata').to_xml)
          raise DiscoveryIndexer::Errors::MissingRightsMetadata.new(@purlxml_ng_doc.inspect) if !ng_doc || ng_doc.children.empty?
          ng_doc
        rescue
          raise DiscoveryIndexer::Errors::MissingRightsMetadata.new(@purlxml_ng_doc.inspect)
        end
      end
        
      # extracts the dc field for this fedora object, from the purl xml
      # @return [Nokogiri::XML::Document] the dc for the fedora object
      # @raise [DiscoveryIndexer::Errors::MissingDC] if there is no dc element
      def parse_dc
          begin
            ng_doc = Nokogiri::XML(@purlxml_ng_doc.root.xpath('/publicObject/dc:dc', {'dc' => OAI_DC_NAMESPACE}).to_xml(:encoding => 'utf-8'))
            raise DiscoveryIndexer::Errors::MissingDC.new(@purlxml_ng_doc.inspect) if !ng_doc || ng_doc.children.empty?
            ng_doc
          rescue
            raise DiscoveryIndexer::Errors::MissingDC.new(@purlxml_ng_doc.inspect)
          end
      end
        
      # extracts the rdf field for this fedora object, from the purl xml
      # @return [Nokogiri::XML::Document] the rdf for the fedora object
      # @raise [DiscoveryIndexer::Errors::MissingRDF] if there is no rdf element
      def parse_rdf
          begin
            ng_doc = Nokogiri::XML(@purlxml_ng_doc.root.xpath('/publicObject/rdf:RDF', {'rdf' => RDF_NAMESPACE}).to_xml)
            raise DiscoveryIndexer::Errors::MissingRDF.new(@purlxml_ng_doc.inspect) if !ng_doc || ng_doc.children.empty?
            ng_doc
          rescue
            raise DiscoveryIndexer::Errors::MissingRDF.new(@purlxml_ng_doc.inspect)
          end
      end
      
      
      # extracts the release tag element for this fedora object, from the the identity metadata in purl xml
      # @return [] the release tags for the fedora object
      def parse_release_tags_hash
          
      end
 
      # extracts the contentMetadata for this fedora object, from the purl xml
      # @return [Nokogiri::XML::Document] the contentMetadata for the fedora object
      # @raise [DiscoveryIndexer::Errors::MissingContentMetadata] if there is no contentMetadata
      def parse_content_metadata
        begin
          ng_doc = Nokogiri::XML(@purlxml_ng_doc.root.xpath('/publicObject/contentMetadata').to_xml)
          raise DiscoveryIndexer::Errors::MissingContentMetadata.new(@purlxml_ng_doc.inspect) if !ng_doc || ng_doc.children.empty?
          ng_doc 
        rescue
          raise DiscoveryIndexer::Errors::MissingContentMetadata.new(@purlxml_ng_doc.inspect)
        end 
      end
    end
  end
end
  