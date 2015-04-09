module DiscoveryIndexer
  module Mapper
    class GeneralMapper
      
      # Initializes an instance from IndexMapper
      # @param [String] druid e.g. ab123cd4567
      # @param [Stanford::Mods::Record] modsxml represents the MODS xml for the druid
      # @param [DiscoveryIndexer::Reader::PurlxmlModel] purlxml represents the purlxml model
      # @param [Hash] collection_names represents a hash of collection_druid and 
      #  collection_name !{"aa111aa1111"=>"First Collection", "bb123bb1234"=>"Second Collection"}
      def initialize(druid, modsxml, purlxml, collection_names={})
        @druid = druid
        @modsxml = modsxml
        @purlxml = purlxml
        @collection_names = collection_names
      end

      # Create a Hash representing a Solr doc, with all MODS related fields populated.  
      # @return [Hash] Hash representing the Solr document
      def convert_to_solr_doc()
        solr_doc = {}
        solr_doc[:id] = @druid
        solr_doc[:title] = @modsxml.sw_full_title
        return solr_doc
      end
    end
  end
end
  