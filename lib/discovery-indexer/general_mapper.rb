module DiscoveryIndexer
  class GeneralMapper

    attr_reader :druid

    # Initializes an instance from IndexMapper
    # @param [String] druid e.g. ab123cd4567
    def initialize(druid)
      @druid = druid
    end

    # Create a Hash representing a Solr doc, with all MODS related fields populated.
    # @return [Hash] Hash representing the Solr document
    def convert_to_solr_doc
      solr_doc = {}
      solr_doc[:id] = druid
      solr_doc[:title] = modsxml.sw_full_title
      solr_doc
    end

    # For each collection druid, return a Hash of coll name (as :title) and ckey. If the druid doesn't
    # have a collection title, it will be excluded from the hash
    # @return [Hash] keys are coll druids, and values are a hash of title and ckey for the coll druid
    # e.g. {'aa00bb0001'=>{:title=>'my coll',:ckey=>'652'},'nt028fd5773'=>{:title=>'Revs coll',:ckey=>'88'}}
    def collection_data
      @collection_data ||= collection_druids.map do |cdruid|
        DiscoveryIndexer::Collection.new(cdruid)
      end
    end

    def collection_druids
      purlxml.collection_druids
    end

    # @return [Stanford::Mods::Record] the MODS xml for the druid
    def modsxml
      @modsxml ||= DiscoveryIndexer::InputXml::Modsxml.new(druid).load
    end

    # @return [DiscoveryIndexer::Reader::PurlxmlModel] the purlxml model
    def purlxml
      @purlxml ||= DiscoveryIndexer::InputXml::Purlxml.new(druid).load
    end
  end
end
