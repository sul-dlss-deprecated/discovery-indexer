module DiscoveryIndexer

  # It caches the collection information such as name and catkey
  class Collection

    attr_reader :druid
    delegate :present?, to: :collection_info

    def initialize(druid)
      @druid = druid
    end

    def searchworks_id
      collection_info[:ckey] || druid
    end

    def title
      collection_info[:title]
    end

    private

    # Returns the collection name from cache, otherwise will fetch it from PURL.
    #
    # @param collection_druid [String]  is the druid for a collection e.g., ab123cd4567
    # @return [Array<String>] the collection data or [] if there is no name and catkey or the object
    #   is not a collection
    def collection_info
      from_purl || {}
    end

    # @param [String] collection_druid is the druid for a collection e.g., ab123cd4567
    # @return [String] return the collection label from purl if available, nil otherwise
    def from_purl
      return unless purl_model
      { title: purl_model.label, ckey: purl_model.catkey }
    end

    def purl_model
      @purl_model ||= begin
        DiscoveryIndexer::InputXml::Purlxml.new(druid).load
      rescue => e
        DiscoveryIndexer::Logging.logger.error "There is a problem in retrieving collection name and/or catkey for #{druid}. #{e.inspect}\n#{e.message }\n#{e.backtrace}"
        nil
      end
    end
  end
end
