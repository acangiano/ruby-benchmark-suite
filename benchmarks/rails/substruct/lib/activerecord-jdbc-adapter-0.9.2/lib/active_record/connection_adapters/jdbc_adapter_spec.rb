module JdbcSpec
  module ActiveRecordExtensions
    def self.add_method_to_remove_from_ar_base(meth)
      @methods ||= []
      @methods << meth
    end

    def self.extended(klass)
      (@methods || []).each {|m| (class << klass; self; end).instance_eval { remove_method(m) rescue nil } }
    end
  end
end

require 'jdbc_adapter/jdbc_mimer'
require 'jdbc_adapter/jdbc_hsqldb'
require 'jdbc_adapter/jdbc_oracle'
require 'jdbc_adapter/jdbc_postgre'
require 'jdbc_adapter/jdbc_mysql'
require 'jdbc_adapter/jdbc_derby'
require 'jdbc_adapter/jdbc_firebird'
require 'jdbc_adapter/jdbc_db2'
require 'jdbc_adapter/jdbc_mssql'
require 'jdbc_adapter/jdbc_cachedb'
require 'jdbc_adapter/jdbc_sqlite3'
require 'jdbc_adapter/jdbc_sybase'
require 'jdbc_adapter/jdbc_informix'
