require "spec_helper"

describe DiscoveryIndexer::InputXml::Purlxml do
      
  VCR.configure do |config|
    config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
    config.hook_into :webmock 
  end
  
  describe ""
end
