module DiscoveryIndexer
  class GeneralMapper

    attr_reader :druid

    # Initializes an instance from IndexMapper
    # @param [String] druid e.g. ab123cd4567
    # @param [Stanford::Mods::Record] modsxml represents the MODS xml for the druid
    # @param [DiscoveryIndexer::Reader::PurlxmlModel] purlxml represents the purlxml model
    # @param [Hash] collection_data represents a hash of collection_druid and catkey
    # collection_data = {'aa00bb0001'=>{:name=>'Test Collection Name',:ckey=>'000001'},'nt028fd5773'=>{:name=>'Revs Institute Archive',:ckey=>'000002'}}
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

    # It converts collection_druids list to a hash with names. If the druid doesn't
    # have a collection name, it will be excluded from the hash
    # @return [Hash] a hash for collection druid and its name
    #   !{"ab123cd4567"=>"Collection 1", "ef123gh4567"=>"Collection 2"}
    def collection_data
      @collection_data ||= collection_druids.map do |cdruid|
        DiscoveryIndexer::Collection.new(cdruid)
      end
    end
    def collection_druids
      purlxml.collection_druids
    end
    def modsxml
      @modsxml ||= DiscoveryIndexer::InputXml::Modsxml.new(druid).load
    end
    def purlxml
      @purlxml ||= DiscoveryIndexer::InputXml::Purlxml.new(druid).load
    end
  end
end
