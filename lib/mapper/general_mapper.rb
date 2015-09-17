module DiscoveryIndexer
  module Mapper
    class GeneralMapper
      # Initializes an instance from IndexMapper
      # @param [String] druid e.g. ab123cd4567
      # @param [Stanford::Mods::Record] modsxml represents the MODS xml for the druid
      # @param [DiscoveryIndexer::Reader::PurlxmlModel] purlxml represents the purlxml model
      # @param [Hash] collection_data represents a hash of collection_druid and catkey
      # e.g. @collection_data = {'aa00bb0001'=>{:name=>'Test Collection Name',:ckey=>'000001'},'nt028fd5773'=>{:name=>'Revs Institute Archive',:ckey=>'000002'}}
      def initialize(druid, modsxml, purlxml, collection_data = {})
        @druid = druid
        @modsxml = modsxml
        @purlxml = purlxml
        @collection_data = collection_data
      end

      # Create a Hash representing a Solr doc, with all MODS related fields populated.
      # @return [Hash] Hash representing the Solr document
      def convert_to_solr_doc
        solr_doc = {}
        solr_doc[:id] = @druid
        solr_doc[:title] = @modsxml.sw_full_title
        solr_doc
      end
    end
  end
end
