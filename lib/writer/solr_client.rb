require 'retries'
require 'rsolr'
require 'rest-client'
module DiscoveryIndexer
  module Writer
    class SolrClient
      include DiscoveryIndexer::Logging

      # Add the document to solr, retry if an error occurs.
      # See https://github.com/ooyala/retries for docs on with_retries.
      # @param [Hash] solr_doc a Hash representation of the solr document
      # @param [RSolr::Client] solr_connector is an open connection with the solr core
      # @param [Integer] max_retries the maximum number of tries before fail
      def self.add(id, solr_doc, solr_connector, max_retries = 10)
        process(id, solr_doc, solr_connector, max_retries, is_delete=false)  
      end

      # Add the document to solr, retry if an error occurs.
      # See https://github.com/ooyala/retries for docs on with_retries.
      # @param [Hash] solr_doc that has only the id !{:id=>"ab123cd4567"}
      # @param [RSolr::Client] solr_connector is an open connection with the solr core
      # @param [Integer] max_retries the maximum number of tries before fail
      def self.delete(id, solr_doc, solr_connector, max_retries = 10)
        process(id, solr_doc, solr_connector, max_retries, is_delete=true)
      end
      
      def self.process(id, solr_doc, solr_connector, max_retries, is_delete=false)
        handler = Proc.new do |exception, attempt_number, total_delay|
          DiscoveryIndexer::Logging.logger.debug "#{exception.class} on attempt #{attempt_number} for #{id}"
        end
          
        with_retries(:max_tries => max_retries, :handler => handler, :base_sleep_seconds => 1, :max_sleep_seconds => 5) do |attempt|
          DiscoveryIndexer::Logging.logger.debug "Attempt #{attempt} for #{id}"
        
          if is_delete
            solr_connector.delete_by_id(id)
            DiscoveryIndexer::Logging.logger.info "Successfully deleted #{id} on attempt #{attempt}"
          elsif allow_update?(solr_connector) && doc_exists?(id,solr_connector)
            update_solr_doc(id,solr_doc,solr_connector)
            DiscoveryIndexer::Logging.logger.info "Successfully updated #{id} on attempt #{attempt}"
          else
            solr_connector.add(solr_doc)
            DiscoveryIndexer::Logging.logger.info "Successfully indexed #{id} on attempt #{attempt}"
          end
          solr_connector.commit
        end
      end
     
      def self.allow_update?(solr_connector)
        return solr_connector.options.include?(:allow_update) ? solr_connector.options[:allow_update] : false
      end
      
      def self.doc_exists?(druid,solr_connector)
        response=solr_connector.get 'select', :params=>{:q=>'id:"' + druid + '"'}  
        response['response']['numFound'] == 1
      end
      
      def self.update_solr_doc(id,solr_doc,solr_connector)
        url="#{solr_connector.options[:url]}update?commit=true"
        puts "#### #{url}"
        params="[{\"id\":\"#{id}\","
        solr_doc.each do |field_name,new_values|
          unless field_name == :id
            params+="\"#{field_name}\":"
            new_values=[new_values] unless new_values.class==Array
            new_values = new_values.map {|s| s.to_s.gsub("\\","\\\\\\").gsub('"','\"').strip} # strip leading/trailing spaces and escape quotes for each value
            params+="{\"set\":[\"#{new_values.join('","')}\"]},"
          end
        end
        params.chomp!(',')
        params+="}]"
       #  params='[{"id":"dw077vs7846","title_variant_display":{"set":"New title"}}]'
        RestClient.post url, params,:content_type => :json, :accept=>:json
      end
      
    end
  end
end