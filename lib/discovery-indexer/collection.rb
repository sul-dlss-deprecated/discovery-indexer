module DiscoveryIndexer

  # Collection information such as name (title/label) and catkey
  class Collection

    attr_reader :druid

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

    # @return [Hash] the collection data as { title: 'coll title', ckey: catkey'}
    def collection_info
      return {} unless purl_model
      @info = {}
      @info = { title: purl_model.label, ckey: purl_model.catkey } if @info.empty?
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
