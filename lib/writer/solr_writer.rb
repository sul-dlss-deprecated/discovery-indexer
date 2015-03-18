require 'retries'
require 'rsolr'

module DiscoveryIndexer
  module Writer
    class SolrWriter
      
      def process(druid, index_doc, targets, solr_targets_configs)
        @solr_targets_configs = solr_targets_configs
        index_targets = []
        delete_targets = []
        puts targets
        targets.keys.each do |target| 
          if targets[target] then
            index_targets.append(target)
          else
            delete_targets.append(target)
          end
        end
        
        # get targets with true
        solr_index_client(index_doc, index_targets)
        # get targets with false
        solr_delete_client(druid, delete_targets)
      end
      
      def solr_delete_from_all(druid, solr_targets_configs)
        # Get a list of all registered targets
        @solr_targets_configs=solr_targets_configs
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
        puts solr_target
        puts @solr_targets_configs
        if @solr_targets_configs.keys.include?(solr_target) then
          config = @solr_targets_configs[solr_target]
          solr_connector = RSolr.connect(config)
        end
        return solr_connector
      end
      
    end
  end
end
