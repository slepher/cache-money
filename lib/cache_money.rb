require 'active_support'
require 'active_record'

require 'cash/version'
require 'cash/lock'
require 'cash/transactional'
require 'cash/write_through'
require 'cash/finders'
require 'cash/buffered'
require 'cash/index'
require 'cash/config'
require 'cash/accessor'

require 'cash/request'
require 'cash/fake'
require 'cash/local'

require 'cash/query/abstract'
require 'cash/query/select'
require 'cash/query/primary_key'
require 'cash/query/calculation'

require 'cash/util/array'
require 'cash/util/marshal'

module Cash
  mattr_accessor :enabled
  self.enabled = true
  
  mattr_accessor :repository
  
  def self.configure(options = {})
    options.assert_valid_keys(:repository, :local, :transactional, :adapter, :default_ttl)
    cache = options[:repository] || raise(":repository is a required option")
    
    adapter = options.fetch(:adapter, :memcached)
    
    if adapter
      require "cash/adapter/#{adapter.to_s}"
      klass = "Cash::Adapter::#{adapter.to_s.camelize}".constantize
      cache = klass.new(cache, :logger => Rails.logger, :default_ttl => options.fetch(:default_ttl, 1.day.to_i))
    end
    
    lock  = Cash::Lock.new(cache)
    cache = Cash::Local.new(cache) if options.fetch(:local, true)
    cache = Cash::Transactional.new(cache, lock) if options.fetch(:transactional, true)
    
    self.repository = cache
  end
  
  def self.included(active_record_class)
    active_record_class.class_eval do
      include Config, Accessor, WriteThrough, Finders
      extend ClassMethods
    end
  end

  private

    def self.repository
      @@repository || raise("Cash.configure must be called when Cash.enabled is true")
    end
  
  module ClassMethods
    def self.extended(active_record_class)
      class << active_record_class
        alias_method_chain :transaction, :cache_transaction
      end
    end

    def transaction_with_cache_transaction(*args, &block)
      if Cash.enabled
        # Wrap both the db and cache transaction in another cache transaction so that the cache 
        # gets written only after the database commit but can still flush the inner cache
        # transaction if an AR::Rollback is issued.
        Cash.repository.transaction do
          transaction_without_cache_transaction(*args) do
            Cash.repository.transaction { block.call }
          end
        end
      else
        transaction_without_cache_transaction(*args, &block)
      end
    end
  end
end

class ActiveRecord::Base
  include Cash
  
  def self.is_cached(options = {})
    options.assert_valid_keys(:ttl, :repository, :version)
    opts = options.dup
    opts[:repository] = Cash.repository unless opts.has_key?(:repository)
    Cash::Config.create(self, opts)
  end

  def <=>(other)
    if self.id == other.id then 
      0
    else
      self.id < other.id ? -1 : 1
    end
  end
end