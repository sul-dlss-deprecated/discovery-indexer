require 'retries'
require 'rsolr'

module DiscoveryIndexer
  module Writer
    class SolrClient
      
      # Add the document to solr, retry if an error occurs.
      # See https://github.com/ooyala/retries for docs on with_retries.
      # @param [Hash] doc a Hash representation of the solr document

      def self.add(solr_doc, solr_connector, max_retries = 10)
        process(solr_doc, solr_connector, max_retries, is_delete=false)  
      end
      
      def self.delete(solr_doc, solr_connector, max_retries = 10)
        process(solr_doc, solr_connector, max_retries, is_delete=true)
      end
      
      def self.process(solr_doc, solr_connector, max_retries, is_delete=false)
       logger  = Logger.new STDOUT
       id = solr_doc[:id]
        puts id
        handler = Proc.new do |exception, attempt_number, total_delay|
          logger.debug "#{exception.class} on attempt #{attempt_number} for #{id}"
        end
        
        with_retries(:max_tries => max_retries, :handler => handler, :base_sleep_seconds => 1, :max_sleep_seconds => 5) do |attempt|
          logger.debug "Attempt #{attempt} for #{id}"
          
          if is_delete
            solr_connector.delete_by_id(id)
            logger.info "Successfully deleted #{id} on attempt #{attempt}"
          else
            solr_connector.add(solr_doc)
            logger.info "Successfully indexed #{id} on attempt #{attempt}"
          end
          
        end
        solr_connector.commit
      end
     
    end
  end
end