[<img src="https://travis-ci.org/sul-dlss/discovery-indexer.svg?branch=master" alt="Build Status" />](https://travis-ci.org/sul-dlss/discovery-indexer)
[![Coverage Status](https://coveralls.io/repos/github/sul-dlss/discovery-indexer/badge.svg?branch=master)](https://coveralls.io/github/sul-dlss/discovery-indexer?branch=master)
[<img src="https://gemnasium.com/sul-dlss/discovery-indexer.svg" alt="Dependency Status" />](https://gemnasium.com/sul-dlss/discovery-indexer)
[<img src="https://badge.fury.io/rb/discovery-indexer.svg" alt="Gem Version" />](http://badge.fury.io/rb/discovery-indexer)

discovery_indexer gem provides the core features required to perform solr indexing from PURL for Stanford University Library digital library websites and Searchworks. 

## Reading XML files
The reader component is responsible for reading both the full public XML and the MODs XML from PURL pages.

## Mapping
The GeneralMapper interface and its implementation, IndexMapper, map the input XML (public and MODs) from the reader to a Solr doc hash. There are two methods to build a specialized indexer for a specific Solr index (such as Searchworks or Revs):

### Inherit from GeneralMapper

    class SpecializedMapper < GeneralMapper
      def initialize(druid, modsxml, purlxml, collection_names={}) # you are provided with mods and purl xml
        super druid, modsxml, purlxml, collection_names
      end  
      
      def map()
	    ...   # you generate a full solr doc hash
		return solr_doc hash
      end
    end
	
## Inherits from IndexMapper
In this case, you will have a solr_doc hash starting point with common solr fields.  You can decorate the hash to further add/remove fields as necessary.

    class SpecializedMapper < IndexMapper
      def initialize(druid, modsxml, purlxml, collection_names={})
        super druid, modsxml, purlxml, collection_names
      end  
      
      def map()
	  	solr_doc = super.map()
		# add remove from solr_doc hash as needed for your app
		return new_solr_doc
      end
    end

## Writing to SOLR
The gem will take of writing the solr doc to a specific solr core URL that is defined in a list of targets with its configuration.
