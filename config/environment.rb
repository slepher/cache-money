require 'action_controller'
require 'active_record'
require 'active_record/session_store'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => ':memory:'
)
