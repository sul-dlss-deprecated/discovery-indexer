module DiscoveryIndexer
  module Mapper
    class GeneralMapper
      
      def initialize(druid, modsxml, purlxml, collection_names={})
        @druid = druid
        @modsxml = modsxml
        @purlxml = purlxml
        @collection_names = collection_names
      end

      def map()
      end
          
    end
  end
end
  