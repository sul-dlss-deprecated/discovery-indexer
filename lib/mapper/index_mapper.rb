module DiscoveryIndexer
  module Mapper
    class IndexerlMapper < GeneralMapper
      # Create a Hash representing a Solr doc, with all MODS related fields populated.
      # @return [Hash] Hash representing the Solr document
     
      def initialize(druid, modsxml, purlxml)
        super druid, modsxml, purlxml
      end  
      def map()
        solr_doc = {}
        solr_doc[:id] = @druid
        solr_doc.update mods_to_title_fields
        solr_doc.update mods_to_author_fields
        solr_doc.update mods_to_subject_search_fields
        solr_doc.update mods_to_publication_fields
        solr_doc.update mods_to_pub_date
        solr_doc.update mods_to_others
        
        solr_doc[:all_search] = @modsxml.text.gsub(/\s+/, ' ')
        return solr_doc
      end

      def mods_to_title_fields
        # title fields
        doc_hash = { 
          :title_245a_search => @modsxml.sw_short_title,
          :title_245_search => @modsxml.sw_full_title,
          :title_variant_search => @modsxml.sw_addl_titles,
          :title_sort => @modsxml.sw_sort_title,
          :title_245a_display => @modsxml.sw_short_title,
          :title_display => @modsxml.sw_title_display,
          :title_full_display => @modsxml.sw_full_title,
        }
        doc_hash
      end
      
      def mods_to_author_fields
        doc_hash = { 
          # author fields
          :author_1xx_search => @modsxml.sw_main_author,
          :author_7xx_search => @modsxml.sw_addl_authors,
          :author_person_facet => @modsxml.sw_person_authors,
          :author_other_facet => @modsxml.sw_impersonal_authors,
          :author_sort => @modsxml.sw_sort_author[1..-1],
          :author_corp_display => @modsxml.sw_corporate_authors,
          :author_meeting_display => @modsxml.sw_meeting_authors,
          :author_person_display => @modsxml.sw_person_authors,
          :author_person_full_display => @modsxml.sw_person_authors,
        }
        doc_hash
      end
      
      def mods_to_subject_search_fields
        doc_hash = { 
          # subject search fields
          :topic_search => @modsxml.topic_search, 
          :geographic_search => @modsxml.geographic_search,
          :subject_other_search => @modsxml.subject_other_search, 
          :subject_other_subvy_search => @modsxml.subject_other_subvy_search,
          :subject_all_search => @modsxml.subject_all_search, 
          :topic_facet => @modsxml.topic_facet,
          :geographic_facet => @modsxml.geographic_facet,
          :era_facet => @modsxml.era_facet,
        }
      end
      
      def mods_to_publication_fields
        doc_hash = { 
          # publication fields
          :pub_search =>  @modsxml.place,
          :pub_date_sort =>  @modsxml.pub_date_sort,
          :imprint_display =>  @modsxml.pub_date_display,
          :pub_date =>  @modsxml.pub_date_facet,
          :pub_date_display =>  @modsxml.pub_date_display, # pub_date_display may be deprecated
        }
      end
      
      def mods_to_pub_date
        doc_hash = {}
        pub_date_sort = @modsxml.pub_date_sort
        if is_positive_int? pub_date_sort
          doc_hash[:pub_year_tisim] =  pub_date_sort # for date slider
          # put the displayable year in the correct field, :creation_year_isi for example
          doc_hash[date_type_sym] =  @modsxml.pub_date_sort  if date_type_sym
        end
        return doc_hash
      end    
        
      def mods_to_others
        doc_hash = { 
          :format_main_ssim => format_main_ssim,
          :format => format, # for backwards compatibility
          :language => @modsxml.sw_language_facet,
          :physical =>  @modsxml.term_values([:physical_description, :extent]),
          :summary_search => @modsxml.term_values(:abstract),
          :toc_search => @modsxml.term_values(:tableOfContents),
          :url_suppl => @modsxml.term_values([:related_item, :location, :url]),
        }
        return doc_hash
      end
    
      # select one or more format values from the controlled vocabulary here:
      #   http://searchworks-solr-lb.stanford.edu:8983/solr/select?facet.field=format&rows=0&facet.sort=index
      # via stanford-mods gem
      # @return [Array<String>] value(s) in the SearchWorks controlled vocabulary, or []
      def format
        vals = @modsxml.format
        if vals.empty?
          @logger.warn "#{@druid} has no SearchWorks format from MODS - check <typeOfResource> and other implicated MODS elements"
        end
        vals
      end
      
      # call stanford-mods format_main to get results
      # @return [Array<String>] value(s) in the SearchWorks controlled vocabulary, or []
      def format_main_ssim
        vals = @modsxml.format_main
        if vals.empty?
          @logger.warn "#{@druid} has no SearchWorks Resource Type from MODS - check <typeOfResource> and other implicated MODS elements"
        end
        vals
      end
    
      # call stanford-mods sw_genre to get results
      # @return [Array<String>] value(s) 
      def genre_ssim
        @modsxml.sw_genre
      end
    
    protected
    
      # @return true if the string parses into an int, and if so, the int is >= 0
      def is_positive_int? str
        begin
          if str.to_i >= 0
            return true
          else
            return false
          end
        rescue
        end
        return false
      end
    
      # determines particular flavor of displayable publication year field 
      # @return Solr field name as a symbol
      def date_type_sym
        vals = @modsxml.term_values([:origin_info,:dateIssued])
        if vals and vals.length > 0
          return :publication_year_isi
        end
        vals = @modsxml.term_values([:origin_info,:dateCreated])  
        if vals and vals.length > 0
          return :creation_year_isi
        end
        nil
      end
      
    end
  end
end
  