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
        find_without_cache(@options1)
      end
    end
  end
end
