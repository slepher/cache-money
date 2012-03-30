module Cash
  module Query
    class Select < Abstract
      delegate :find_by_sql_without_cache, :to => :@active_record

      protected
      def miss(_, miss_options)
        arel = miss_options[:conditions]
        find_by_sql_without_cache(arel, @binds)
      end

      def uncacheable
        arel = @options1[:conditions]
        find_by_sql_without_cache(arel, @binds)
      end
    end
  end
end
