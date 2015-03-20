[<img src="https://travis-ci.org/sul-dlss/discovery-indexer.svg?branch=master" alt="Build Status" />](https://travis-ci.org/sul-dlss/discovery-indexer)
[<img src="https://coveralls.io/repos/sul-dlss/discovery-indexer/badge.png" alt="Coverage Status" />](https://coveralls.io/r/sul-dlss/discovery-indexer)
[<img src="https://gemnasium.com/sul-dlss/discovery-indexer.svg" alt="Dependency Status" />](https://gemnasium.com/sul-dlss/discovery-indexer)
[<img src="https://badge.fury.io/rb/discovery-indexer.svg" alt="Gem Version" />](http://badge.fury.io/rb/discovery-indexer)

discovery_indexer gem combines the basic features that are required to perform the indexing tasks for Stanford University Library digital library. 

## Reading XML files
Reader component is responsible of reading both of purl public xml and mods xml.

## Mapping
GeneralMapper interface and its implementaion IndexMapper are mapping the input XML from the input models to solr doc hash. There are two methods to build specialized indexer:

### Inherits from GeneralMapper

    class SpecializedMapper < GeneralMapper
      def initialize(druid, modsxml, purlxml, collection_names={})
        super druid, modsxml, purlxml, collection_names
      end  
      
      def map()
	    ...
		return solr_doc
      end
    end
	
## Inherits from IndexMapper
In this case, you will get benefits from the general implementation for the solr_doc. You can decorate the output to add/remove the fields.

    class SpecializedMapper < IndexMapper
      def initialize(druid, modsxml, purlxml, collection_names={})
        super druid, modsxml, purlxml, collection_names
      end  
      
      def map()
	  	solr_doc = super.map()
		# add remove from solr_doc
		return new_solr_doc
      end
    end

## Writing to SOLR
It supports writing the solr doc to solr core that is defined in a list of targets with its configuration.
