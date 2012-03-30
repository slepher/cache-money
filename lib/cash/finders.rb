module Cash
  module Finders
    def self.included(active_record_class)
      active_record_class.class_eval do
        extend ClassMethods
      end
    end

    module ClassMethods
      def self.extended(active_record_class)
        class << active_record_class
          alias_method_chain :find_by_sql, :cache
        end
      end

      def without_cache(&block)
        with_scope(:find => {:readonly => true}, &block)
      end

      def find_by_sql_with_cache(sql, binds)
        if cacheable?
          if sql.where_sql
            Query::Select.perform(self, { :conditions => sql, :binds => binds}, binds)
          else
            find_by_sql_without_cache(sql, binds)
          end
        else
          find_by_sql_without_cache(sql, binds)
        end
      end

      def find_without_cache(*args)
        find(*args)
      end
      
      def calculate_without_cache(*args)
        calculate(*args)
      end
    end
  end
end
