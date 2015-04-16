require 'retries'
require 'rsolr'

module DiscoveryIndexer
  module Writer
    class SolrWriter
      include DiscoveryIndexer::Logging
      
      def process(id, index_doc, targets, solr_targets_configs)
        @solr_targets_configs = solr_targets_configs
        index_targets = []
        delete_targets = []
        targets.keys.each do |target| 
          if targets[target] then
            index_targets.append(target)
          else
            delete_targets.append(target)
          end
        end
        
        # get targets with true
        solr_index_client(id, index_doc, index_targets)
        # get targets with false
        solr_delete_client(id, delete_targets)
      end
      
      def solr_delete_from_all(id, solr_targets_configs)
        # Get a list of all registered targets
        @solr_targets_configs=solr_targets_configs
        targets = @solr_targets_configs.keys()
        solr_delete_client(id, targets)
      end
            
      def solr_index_client(id, index_doc, targets)
        targets.each do |solr_target|
          solr_connector = get_connector_for_target(solr_target)     
          SolrClient.add(id, index_doc, solr_connector) unless solr_connector.nil?
        end          
      end
      
      def solr_delete_client(id, targets)
        targets.each do |solr_target|
          solr_connector = get_connector_for_target(solr_target)
          SolrClient.delete(id, solr_connector) unless solr_connector.nil?
        end         
      end

      def get_connector_for_target(solr_target)
        solr_connector = nil
        if @solr_targets_configs.keys.include?(solr_target) then
          config = @solr_targets_configs[solr_target]
          solr_connector = RSolr.connect(config.deep_symbolize_keys)
        end
        return solr_connector
      end
      
    end
  end
end
