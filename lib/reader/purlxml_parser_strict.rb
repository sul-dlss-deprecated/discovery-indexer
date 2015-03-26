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
        purlxml_model.public_xml        = @purlxml_ng_doc
        purlxml_model.content_metadata  = parse_content_metadata()        
        purlxml_model.identity_metadata = parse_identity_metadata()
        purlxml_model.rights_metadata   = parse_rights_metadata()
        purlxml_model.dc                = parse_dc()
        purlxml_model.rdf               = parse_rdf()
        purlxml_model.is_collection     = parse_is_collection()
        purlxml_model.collection_druids =  parse_collection_druids()
        purlxml_model.dor_content_type  = parse_dor_content_type()
        purlxml_model.release_tags_hash = parse_release_tags_hash()
        purlxml_model.file_ids          = parse_file_ids()
        purlxml_model.image_ids         = parse_image_ids()
        purlxml_model.catkey            = parse_catkey()
        purlxml_model.barcode           = parse_barcode()
        purlxml_model.label             = parse_label()
        purlxml_model.copyright         = parse_copyright()
        purlxml_model.use_and_reproduction = parse_use_and_reproduction()
        purlxml_model.source_id  = parse_sourceid()
        return purlxml_model
      end
      
      # extracts the identityMetadata for this fedora object, from the purl xml
      # @return [Nokogiri::XML::Document] the identityMetadata for the fedora object
      # @raise [DiscoveryIndexer::Errors::MissingIdentityMetadata] if there is no identity_metadata
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
      # @return [Hash] the release tags for the fedora object
      def parse_release_tags_hash
        release_tags={}
        identity_metadata  = parse_identity_metadata
        unless identity_metadata.nil?
          release_elements = identity_metadata.xpath('//release')
          release_elements.each { |n| 
            unless n.attr("to").nil?
              release_target = n.attr("to")
              
              
              #target = release_target.split(":").first
              #sub_target = "default"
              #if target != release_target.split(":").last then
              #  sub_target = release_target.split(":").last
              #end
              text = n.text
              unless text.nil? 
                release_tags[release_target]= text 
              end
            end
          }
          return release_tags
        end
      end
 
      # extracts the contentMetadata for this fedora object, from the purl xml
      # @return [Nokogiri::XML::Document] the contentMetadata for the fedora object
      # @raise [DiscoveryIndexer::Errors::MissingContentMetadata] if there is no contentMetadata
      def parse_content_metadata
          ng_doc = Nokogiri::XML(@purlxml_ng_doc.root.xpath('/publicObject/contentMetadata').to_xml)
          ng_doc = nil if !ng_doc || ng_doc.children.empty?
          ng_doc 
      end
      
      # @return true if the identityMetadata has <objectType>collection</objectType>, false otherwise
      def parse_is_collection
        identity_metadata  = parse_identity_metadata
        unless identity_metadata.nil?
          object_type_nodes = identity_metadata.xpath('./objectType')
          return true if object_type_nodes.find_index { |n| n.text == 'collection'}
        end
        false
      end
      
      # get the druids from isMemberOfCollection relationships in rels-ext from public_xml
      # @return [Array<String>] the druids (e.g. ww123yy1234) this object has isMemberOfColletion relationship with, or nil if none
      def parse_collection_druids
        ns_hash = {'rdf' => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#', 'fedora' => "info:fedora/fedora-system:def/relations-external#", '' => ''}
        is_member_of_nodes ||= @purlxml_ng_doc.xpath('/publicObject/rdf:RDF/rdf:Description/fedora:isMemberOfCollection/@rdf:resource', ns_hash)
        # from public_xml rels-ext
        druids = []
        is_member_of_nodes.each { |n| 
          druids << n.value.split('druid:').last unless n.value.empty?
        }
        return nil if druids.empty?
        druids
      end
      
      # the value of the type attribute for a DOR object's contentMetadata
      #  more info about these values is here:
      #    https://consul.stanford.edu/display/chimera/DOR+content+types%2C+resource+types+and+interpretive+metadata
      #    https://consul.stanford.edu/display/chimera/Summary+of+Content+Types%2C+Resource+Types+and+their+behaviors
      # @return [String] 
      def parse_dor_content_type
        content_md = parse_content_metadata
        dct = content_md ? content_md.xpath('contentMetadata/@type').text : nil
        puts " has no DOR content type (<contentMetadata> element may be missing type attribute)" if !dct || dct.empty?
        dct
      end
      
      # the @id attribute of resource/file elements that match the image type, including extension
      # @return [Array<String>] filenames
      def parse_image_ids
          ids = []
          content_md = parse_content_metadata
          unless content_md.nil?
            content_md.xpath('//resource[@type="image"]/file/@id').each { |node|
              ids << node.text if !node.text.empty?
            }
          return nil if ids.empty?
          ids
        end
      end

      def parse_sourceid
        get_value(@purlxml_ng_doc.css('//identityMetadata/sourceId'))
      end
            
      def parse_copyright
        get_value(@purlxml_ng_doc.css('//rightsMetadata/copyright/human[type="copyright"]'))
      end
  
      def parse_use_and_reproduction
        get_value(@purlxml_ng_doc.css('//rightsMetadata/use/human[type="useAndReproduction"]'))
      end
      
      # the @id attribute of resource/file elements, including extension
      # @return [Array<String>] filenames
      def parse_file_ids
        ids = []
        content_md = parse_content_metadata
        unless content_md.nil?
            content_md.xpath('//resource/file/@id').each { |node|
              ids << node.text if !node.text.empty?
            }
          return nil if ids.empty?
          ids
        end 
      end
      
      # @return catkey value from the DOR identity_metadata, or nil if there is no catkey
      def parse_catkey
        get_value(@purlxml_ng_doc.xpath("/publicObject/identityMetadata/otherId[@name='catkey']"))
      end

      # @return barcode value from the DOR identity_metadata, or nil if there is no barcode
      def parse_barcode
        get_value(@purlxml_ng_doc.xpath("/publicObject/identityMetadata/otherId[@name='barcode']"))
      end

      # @return objectLabel value from the DOR identity_metadata, or nil if there is no barcode
      def parse_label
        get_value(@purlxml_ng_doc.xpath("/publicObject/identityMetadata/objectLabel"))
      end
      
      def get_value(node)
        (node && node.first) ? node.first.content : nil 
      end
      
    end
  end
end
  