module Cash
  module Query
    class Select < Abstract
      delegate :find_by_sql_without_cache, :to => :@active_record

      protected
      def miss(_, miss_options)
        arel = miss_options[:conditions]
        binds = miss_options[:binds]
        find_by_sql_without_cache(arel, binds)
      end

      def uncacheable
        arel = @options1[:conditions]
        binds = @options1[:binds]
        find_by_sql_without_cache(arel, binds)
      end
    end
  end
end
