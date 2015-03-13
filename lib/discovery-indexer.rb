require 'reader/purlxml'
require 'reader/purlxml_reader'
require 'reader/purlxml_parser'
require 'reader/purlxml_parser_strict'
require 'reader/purlxml_model'

require 'reader/modsxml'
require 'reader/modsxml_reader'

require 'mapper/general_mapper'
require 'mapper/index_mapper'

require 'writer/solr_client'
require 'writer/solr_writer'

require 'errors'

module DiscoveryIndexer
  PURL_DEFAULT = 'http://purl.stanford.edu'
end