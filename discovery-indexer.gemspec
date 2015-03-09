lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
require 'version'

Gem::Specification.new do |s|
  s.name        = 'discovery-indexer'
  s.version     = DiscoveryIndexer::VERSION
  s.licenses    = ['Stanford University']
  s.summary     = "Shared library for the basic discovery indexing operation for Stanford DLSS."
  s.description = "This library manages the core operations for the discovery indexing such as reading PURL xml, mapping to the solr document, and writing to solr core."
  s.authors     = ["Ahmed AlSum"]
  s.email       = 'aalsum@stanford.edu'
  s.files        = Dir.glob("lib/*") + Dir.glob("lib/**/*") + Dir.glob("config/**/*") + Dir.glob('bin/*')
  s.require_path = 'lib'
  
  
  
  spec.add_development_dependency "rspec"

  
  
  
  
end