require 'nokogiri'
require 'open-uri'
module DiscoveryIndexer
  module InputXml
    class ModsxmlReader
      # reads the mods xml for the fedora object that is defined , from the purl server
      # @param [String] druid e.g. ab123cd4567
      # @return [Nokogiri::XML::Document] the mods xml for the fedora object
      # @raise [MissingModsXml] if there's no mods xml available for this druid
      def self.read(druid)
        mods_uri = "#{DiscoveryIndexer::PURL_DEFAULT}/#{druid}.mods"
        begin
          Nokogiri::XML(open(mods_uri))
        rescue
          raise DiscoveryIndexer::Errors::MissingModsPage.new(mods_uri)
        end
      end
    end
  end
end
