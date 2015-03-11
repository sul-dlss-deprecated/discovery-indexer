lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
require 'version'

Gem::Specification.new do |gem|
  gem.name        = 'discovery-indexer'
  gem.version     = DiscoveryIndexer::VERSION
  gem.licenses    = ['Stanford University']
  gem.summary     = "Shared library for the basic discovery indexing operation for Stanford DLSS."
  gem.description = "This library manages the core operations for the discovery indexing such as reading PURL xml, mapping to the solr document, and writing to solr core."
  gem.authors     = ["Ahmed AlSum"]
  gem.email       = 'aalsum@stanford.edu'
  gem.files        = Dir.glob("lib/**/*") + Dir.glob("config/**/*") + Dir.glob('bin/*')
  gem.require_path = 'lib'
  
  gem.add_dependency 'nokogiri'
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "webmock"
  gem.add_development_dependency "rest-client"
  gem.add_development_dependency "equivalent-xml"
  gem.add_development_dependency "vcr"
  
  
  
end