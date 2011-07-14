dir = File.dirname(__FILE__)
$LOAD_PATH.unshift "#{dir}/../lib"

require File.join(dir, '../config/environment')
require 'spec'
require 'pp'
require 'cache_money'
#require 'memcache'
require 'memcached'
require 'cash/adapter/memcached'

Spec::Runner.configure do |config|
  config.mock_with :rr
  config.before :suite do
    load File.join(dir, "../db/schema.rb")

    config = YAML.load(IO.read((File.expand_path(File.dirname(__FILE__) + "/../config/memcached.yml"))))['test']
    
    # Test with memcached client
    $memcache = Cash::Adapter::Memcached.new(Memcached.new(config["servers"].gsub(' ', '').split(','), config), 
      :default_ttl => 1.minute)
    
    # # Test with MemCache client
    # require 'cash/adapter/memcache_client'
    # $memcache = Cash::Adapter::MemcacheClient.new(MemCache.new('127.0.0.1'))
  end

  config.before :each do
    $memcache.flush_all
    Story.delete_all
    Character.delete_all
  end

  config.before :suite do
    Cash.configure :repository => $memcache, :adapter => false
    
    ActiveRecord::Base.class_eval do
      is_cached
    end

    Character = Class.new(ActiveRecord::Base)
    Story = Class.new(ActiveRecord::Base)
    Story.has_many :characters

    Story.class_eval do
      index :title
      index [:id, :title]
      index :published
    end

    Short = Class.new(Story)
    Short.class_eval do
      index :subtitle, :order_column => 'title'
    end

    Epic = Class.new(Story)
    Oral = Class.new(Epic)

    Character.class_eval do
      index [:name, :story_id]
      index [:id, :story_id]
      index [:id, :name, :story_id]
    end

    Oral.class_eval do
      index :subtitle
    end
  end
end
