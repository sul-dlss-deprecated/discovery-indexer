require 'stanford-mods'
module DiscoveryIndexer
  module InputXml
    # This class is the main class to access and parse the mods xml
    #    as retrieved from PURL server
    # @example to run the code
    #  druid = "aa111aa1111"
    #  p =  DiscoveryIndexer::InputXml::Modsxml.new(druid)
    #  model =  p.load()
    #
    #
    class Modsxml
      # initializes a new object
      # @param druid [String] the druid object in the format "aa111aa1111"
      def initialize(druid)
        @druid = druid
        @modsxml_ng_doc = nil
      end

      # loads the mods xml to stanford mods model for the fedora object defind in the druid,
      # it reads the mods xml once from PURL server, and repeat the parsing with each call
      # @return [Stanford::Mods::Record] represents the mods xml
      def load
        @modsxml_ng_doc = ModsxmlReader.read(@druid) if @modsxml_ng_doc.nil?

        modsxml_model = Stanford::Mods::Record.new
        modsxml_model.from_nk_node(@modsxml_ng_doc)
      end
    end
  end
end
