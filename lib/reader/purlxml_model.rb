module DiscoveryIndexer
  module InputXml
    class PurlxmlModel
      
      #@!attribute [rw] public_xml
      # @return [Nokogiri::XML] The publix xml as retrieved from purl server 
      attr_accessor :public_xml

      #@!attribute [rw] content_metadata
      # @return [Nokogiri::XML] The content_metadata as extracted from public xml
      attr_accessor :content_metadata

      #@!attribute [rw] identity_metadata
      # @return [Nokogiri::XML] The identity_metadata as extracted from public xml
      attr_accessor :identity_metadata

      #@!attribute [rw] rights_metadata
      # @return [Nokogiri::XML] The rights_metadata as extracted from public xml
      attr_accessor :rights_metadata

      #@!attribute [rw] dc
      # @return [Nokogiri::XML] The dc element as extracted from public xml
      attr_accessor :dc
      
      #@!attribute [rw] rdf
      # @return [Nokogiri::XML] The rdf element as extracted from public xml
      attr_accessor :rdf

      # @!attribute [rw] release_tags_hash
      # @return [Hash] The release_tag in hash format asextracted from public xml
      #  identity_metadata. 
      # @example
      #  !{"target1"=>true, "target2"=>false}
      attr_accessor :release_tags_hash     

      # @!attribute [rw] dor_content_type
      # @return [String] The dor_content_type as extracted from public xml
      #  content_metadata.
      attr_accessor :dor_content_type
      
      # @!attribute [rw] is_collection
      # @return [Boolean] true if the item type is collection in the identity_metadata
      attr_accessor :is_collection
      
      # @!attribute [rw] collection_druids
      # @return [Array] a list of the collections that this is druid belongs to
      # @example
      #  ["aa11aaa1111","bb111bb1111"]
      attr_accessor :collection_druids
      
      # @!attribute [rw] file_ids
      # @return [Array] a list of the file ids in the content_metadata
      # @example
      #  ["pc0065_b08_f10_i031.txt","pc0065_b08_f10_i032.txt"]   
      attr_accessor :file_ids

      # @!attribute [rw] image_ids
      # @return [Array] a list of the image ids in the content_metadata
      # @example
      #  ["pc0065_b08_f10_i031.jp2","pc0065_b08_f10_i032.jp2"]   
      attr_accessor :image_ids
      
      # @!attribute [rw] catkey
      # @return [String] the catkey attribute in identity_metadata
      attr_accessor :catkey

      # @!attribute [rw] barcode
      # @return [String] the barcode attribute in identity_metadata
      attr_accessor :barcode
      
      # @!attribute [rw] label
      # @return [String] the objectLabel attribute in identity_metadata
      attr_accessor :label
 
      # @!attribute [rw] copyright
      # @return [String] the copyright statement from rights metadata
      attr_accessor :copyright
      
      # @!attribute [rw] use_and_reproduction
      # @return [String] the use and reproduction statement from rights metadata
      attr_accessor :use_and_reproduction
      
    end
  end
end
  





