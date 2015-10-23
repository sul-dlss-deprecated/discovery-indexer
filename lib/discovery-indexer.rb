require 'errors'
require 'logging'

require 'reader/purlxml'
require 'reader/purlxml_reader'
require 'reader/purlxml_parser'
require 'reader/purlxml_parser_strict'
require 'reader/purlxml_model'

require 'reader/modsxml'
require 'reader/modsxml_reader'

require 'mapper/general_mapper'

require 'writer/solr_client'
require 'writer/solr_writer'

# require 'utilities/extract_sub_targets'

module DiscoveryIndexer
  PURL_DEFAULT = 'https://purl.stanford.edu'
end
