require 'logger'

module DiscoveryIndexer
  module Logging
    class << self
      def logger
        @logger ||= Logger.new(STDOUT)
      end
  
      def logger=(logger)
        @logger = logger
      end
    end

  end
end