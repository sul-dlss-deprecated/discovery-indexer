require 'logger'

module DiscoveryIndexer
  module Logging
    class << self
      def logger
        @logger ||= Logger.new(STDOUT)
      end

      attr_writer :logger
    end
  end
end
