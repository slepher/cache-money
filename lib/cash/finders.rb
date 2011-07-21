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
          alias_method_chain :find_every, :cache
          alias_method_chain :find_from_ids, :cache
          alias_method_chain :calculate, :cache
        end
      end

      def without_cache(&block)
        with_scope(:find => {:readonly => true}, &block)
      end

      # User.find(:first, ...), User.find_by_foo(...), User.find(:all, ...), User.find_all_by_foo(...)
      def find_every_with_cache(options)
        if cacheable?
          Query::Select.perform(self, options, scope(:find))
        else
          find_every_without_cache(options)
        end
      end

      # User.find(1), User.find(1, 2, 3), User.find([1, 2, 3]), User.find([])
      def find_from_ids_with_cache(ids, options)
        if cacheable?
          Query::PrimaryKey.perform(self, ids, options, scope(:find))
        else
          find_from_ids_without_cache(ids, options)
        end
      end

      # User.count(:all), User.count, User.sum(...)
      def calculate_with_cache(operation, column_name, options = {})
        if cacheable?
          Query::Calculation.perform(self, operation, column_name, options, scope(:find))
        else
          calculate_without_cache(operation, column_name, options)
        end
      end
    end
  end
end
