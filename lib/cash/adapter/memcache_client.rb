require 'memcache'

module Cash
  module Adapter
    class MemcacheClient
      def initialize(repository, options = {})
        @repository = repository
        @logger = options[:logger]
        @default_ttl = options[:default_ttl]
      end

      def exception_classes
        MemCache::MemCacheError
      end
      
      def respond_to?(method)
        super || @repository.respond_to?(method)
      end
      
      private
      
        def method_missing(*args, &block)
          @repository.send(*args, &block)
        end
        
    end
  end
end