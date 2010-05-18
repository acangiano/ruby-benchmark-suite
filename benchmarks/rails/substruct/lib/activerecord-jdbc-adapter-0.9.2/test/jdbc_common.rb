# Simple method to reduce the boilerplate
def jruby?
  defined?(RUBY_ENGINE) && RUBY_ENGINE == "jruby"
end

require 'rubygems'
# Specify version of activerecord with ENV['AR_VERSION'] if desired
gem 'activerecord', ENV['AR_VERSION'] if ENV['AR_VERSION']
require 'active_record/version'
require 'jdbc_adapter' if jruby?
puts "Using activerecord version #{ActiveRecord::VERSION::STRING}"
puts "Specify version with AR_VERSION=={version} or RUBYLIB={path}"
require 'models/auto_id'
require 'models/entry'
require 'models/data_types'
require 'models/add_not_null_column_to_table'
require 'models/validates_uniqueness_of_string'
require 'simple'
require 'has_many_through'
require 'helper'
require 'test/unit'

# Comment/uncomment to enable logging to be loaded for any of the database adapters
# require 'db/logger'


