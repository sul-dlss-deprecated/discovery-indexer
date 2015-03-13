require 'retries'
require 'rsolr'

module DiscoveryIndexer
  module Writer
    class SolrWriter
      
      def process(druid, index_doc, targets, solr_targets_configs)
        @solr_targets_configs = solr_targets_configs
        # get targets with true
        solr_index_client(index_doc, true_targets)
        # get targets with false
        solr_delete_client(druid, false_targets)
      end
      
      def solr_delete_from_all(druid)
        # Get a list of all registered targets
        targets = @solr_targets_configs.keys()
        solr_delete_client(druid, targets)
      end
            
      def solr_index_client(index_doc, targets)
        targets.each do |solr_target|
          solr_connector = get_connector_for_target(solr_target)     
           SolrClient.add(index_doc, solr_connector)
        end          
      end
      
      def solr_delete_client(druid, targets)
        targets.each do |solr_target|
          solr_connector = get_connector_for_target(solr_target)     
          SolrClient.delete({:id=>druid}, solr_connector)
        end         
      end

      def get_connector_for_target(solr_target)
        solr_connector = nil
        if @solr_targets_configs.include?(solr_target) then
          config = @solr_targets_configs[solr_target]
          solr_connector = RSolr.connect(config)
        end
        return solr_connector
      end
      
    end
  end
end
