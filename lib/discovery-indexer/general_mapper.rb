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

    # @return [DiscoveryIndexer::Collection] for each collection druid, or [] if no collection druids
    def collection_data
      @collection_data ||= collection_druids.map do |cdruid|
        DiscoveryIndexer::Collection.new(cdruid)
      end
    end

    # @return [Array<String>] Array of bare druids from rels-ext isMemberOfCollection in public xml (e.g. ['oo000oo0000'])
    def collection_druids
      purlxml.collection_druids
    end

    # @return [DiscoveryIndexer::Collection] for each constituent druid, or [] if no constituent druids
    def constituent_data
      @constituent_data ||= constituent_druids.map do |cdruid|
        DiscoveryIndexer::Collection.new(cdruid)
      end
    end

    # @return [Array<String>] Array of bare druids from rels-ext isConstituentOf in public xml (e.g. ['oo000oo0000'])
    def constituent_druids
      purlxml.constituent_druids
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
