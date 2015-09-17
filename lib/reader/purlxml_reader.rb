require 'nokogiri'
require 'open-uri'
module DiscoveryIndexer
  module InputXml
    class PurlxmlReader
      # reads the public xml for the fedora object that is defined , from the purl server
      # @param [String] druid e.g. ab123cd4567
      # @return [Nokogiri::XML::Document] the public xml for the fedora object
      # @raise [MissingPublicXml] if there's no purl xml available for this druid
      def self.read(druid)
        purlxml_uri = "#{DiscoveryIndexer::PURL_DEFAULT}/#{druid}.xml"

        begin
          purlxml_object = Nokogiri::XML(open(purlxml_uri))
          return purlxml_object
        rescue
          raise DiscoveryIndexer::Errors::MissingPurlPage.new(purlxml_uri)
        end
      end
    end
  end
end
