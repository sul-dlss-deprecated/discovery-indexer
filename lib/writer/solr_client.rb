require 'retries'
require 'rsolr'
require 'rest-client'
module DiscoveryIndexer
  module Writer
    class SolrClient
      include DiscoveryIndexer::Logging

      # Add the document to solr, retry if an error occurs.
      # See https://github.com/ooyala/retries for docs on with_retries.
      # @param id [String] the document id, usually it will be druid.
      # @param solr_doc [Hash] a Hash representation of the solr document
      # @param solr_connector [RSolr::Client]  is an open connection with the solr core
      # @param max_retries [Integer] the maximum number of tries before fail
      def self.add(id, solr_doc, solr_connector, max_retries = 10)
        process(id, solr_doc, solr_connector, max_retries, is_delete=false)  
      end

      # Add the document to solr, retry if an error occurs.
      # See https://github.com/ooyala/retries for docs on with_retries.
      # @param id [String] the document id, usually it will be druid.
      # @param solr_connector[RSolr::Client]  is an open connection with the solr core
      # @param max_retries [Integer] the maximum number of tries before fail
      def self.delete(id, solr_connector, max_retries = 10)
        process(id, {}, solr_connector, max_retries, is_delete=true)
      end

      # It's an internal method that receives all the requests and deal with
      # SOLR core. This method can call add, delete, or update
      #
      # @param id [String] the document id, usually it will be druid.
      # @param solr_doc [Hash] is the solr doc in hash format 
      # @param solr_connector [RSolr::Client]  is an open connection with the solr core
      # @param max_retries [Integer] the maximum number of tries before fail
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

      # @param solr_connector [RSolr::Client]  is an open connection with the solr core
      # @return [Boolean] true if the solr core allowing update feature
      def self.allow_update?(solr_connector)
        return solr_connector.options.include?(:allow_update) ? solr_connector.options[:allow_update] : false
      end

      # @param id [String] the document id, usually it will be druid.
      # @param solr_connector [RSolr::Client]  is an open connection with the solr core
      # @return [Boolean] true if the solr doc defined by this id exists
      def self.doc_exists?(id,solr_connector)
        response=solr_connector.get 'select', :params=>{:q=>'id:"' + id + '"'}  
        response['response']['numFound'] == 1
      end
      
      # It is an internal method that updates the solr doc instead of adding a new one.
      def self.update_solr_doc(id,solr_doc,solr_connector)
        # update_solr_doc can't used RSolr because updating hash doc is not supported
        #  so we need to build the json input manually
        solr_url = solr_connector.options[:url]
        if solr_url.end_with?("/") then
          url="#{solr_connector.options[:url]}update?commit=true"
        else
          url="#{solr_connector.options[:url]}/update?commit=true"
        end
          
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
        RestClient.post url, params,:content_type => :json, :accept=>:json
      end
      
    end
  end
end