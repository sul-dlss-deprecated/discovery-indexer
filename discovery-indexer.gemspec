lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)
require 'discovery-indexer/version'

Gem::Specification.new do |gem|
  gem.name        = 'discovery-indexer'
  gem.version     = DiscoveryIndexer::VERSION
  gem.licenses    = ['Stanford University']
  gem.summary     = 'Shared library for the basic discovery indexing operation for Stanford DLSS.'
  gem.description = 'This library manages the core operations for the discovery indexing such as reading PURL xml, mapping to the solr document, and writing to solr core.'
  gem.authors     = ['Ahmed AlSum', 'Laney McGlohon']
  gem.email       = 'laneymcg@stanford.edu'
  gem.files        = Dir.glob('lib/**/*') + Dir.glob('config/**/*') + Dir.glob('bin/*')
  gem.require_path = 'lib'

  gem.add_dependency 'nokogiri'
  gem.add_dependency 'stanford-mods', '~>2.1'
  gem.add_dependency 'retries'
  gem.add_dependency 'rsolr'
  gem.add_dependency 'rest-client'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'webmock'
  gem.add_development_dependency 'equivalent-xml'
  gem.add_development_dependency 'vcr'
  gem.add_development_dependency 'yard'
  gem.add_development_dependency 'rubocop'
  gem.add_development_dependency 'rubocop-rspec'

end
