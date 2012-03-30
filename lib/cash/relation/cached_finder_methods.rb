module Cash
  module Relation
    module CachedFinderMethods

      def find_one_with_cache(id)
        id = id.id if ActiveRecord::Base === id

        record = @klass.get(id) do
          find_one_without_cache(id)
        end
        
        unless record
          conditions = arel.wheres.map { |x| x.value }.join(', ')
          conditions = " [WHERE #{conditions}]" if conditions.present?
          raise RecordNotFound, "Couldn't find #{@klass.name} with ID=#{id}#{conditions}"
        end

        record
      end

      def find_some_without_cache_public(*args)
        find_some_without_cache(*args)
      end

      def find_with_ids_with_cache(ids)
        if cacheable?
          Query::PrimaryKey.perform(self, ids, { }, { })
        else
          find_with_ids_without_cache(ids, options)
        end
      end
      
      def find_with_ids_with_cache_bak(ids)
        result = @klass.get(ids) do
          find_with_id_without_cache(ids)
        end
        
        result = ids.collect { |id| result[@klass.cache_key(id)] }.flatten.compact

        expected_size =
          if @limit_value && ids.size > @limit_value
            @limit_value
          else
            ids.size
          end

        # 11 ids with limit 3, offset 9 should give 2 results.
        if @offset_value && (ids.size - @offset_value < expected_size)
          expected_size = ids.size - @offset_value
        end

        if result.size == expected_size
          result
        else
          debugger
          conditions = arel.wheres.map { |x| x.value }.join(', ')
          conditions = " [WHERE #{conditions}]" if conditions.present?

          error = "Couldn't find all #{@klass.name.pluralize} with IDs "
          error << "(#{ids.join(", ")})#{conditions} (found #{result.size} results, but was looking for #{expected_size})"
          raise RecordNotFound, error
        end
      end
    end
  end
end
