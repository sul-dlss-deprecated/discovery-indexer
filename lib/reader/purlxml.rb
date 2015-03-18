module DiscoveryIndexer
  module InputXml
    
    # This class is the main class to access and parse the purl xml 
    #    as retrieved from PURL server
    # @example to run the code
    # druid = "aa111aa1111"
    # p =  DiscoveryIndexer::InputXml::Purlxml.new(druid)
    # model =  p.load()
    # 
    class Purlxml
      
      # initializes a new object 
      # @param druid [String] the druid object in the format "aa111aa1111"
      def initialize(druid)
        @druid = druid
        @purlxml_ng_doc = nil 
      end

      # loads the purl xml to purlxml model for the fedora object defind in the druid,
      #    it reads the purl xml once from PURL server, and repeat the parsing with each call
      # @return [PurlxmlModel] represents the purlxml 
      def load()
        if @purlxml_ng_doc.nil? then
          @purlxml_ng_doc = PurlxmlReader.read(@druid)
        end
        
        purlxml_parser = PurlxmlParserStrict.new(@purlxml_ng_doc)
        purlxml_model = purlxml_parser.parse()
        return purlxml_model
      end
      
      # loads the purl xml to purlxml model for the fedora object defind in the druid
      #    it reads the purl xml from PURL server with every call
      # @return [PurlxmlModel] represents the purlxml 
      def reload()
        @purlxml_ng_doc = PurlxmlReader.read(@druid)
        return load()
      end
  	end
  end
end
  