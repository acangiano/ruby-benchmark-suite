require 'sqlite3/driver/native/Community.Data.SQLite'

module SQLite3 ; module Driver ; module Native

  class CallbackData
    attr_accessor :proc, :proc2, :data
  end

  class Driver
    include CS_SQLite3

    def initialize
      @callback_data = Hash.new
      @authorizer = Hash.new
      @busy_handler = Hash.new
      @trace = Hash.new
    end

    def complete?( sql, utf16=false )
      CSSQLite.sqlite3_complete(sql) != 0
    end

    def open(filename)
      CSSQLite.sqlite3_open( filename, nil )
    end

    def prepare(db, sql)
      CSSQLite.sqlite3_prepare( db, sql, -1, nil, nil )
    end

    def bind_text( stmt, index, value, utf16=false )
      CSSQLite.sqlite3_bind_text( stmt, index, value.to_s, -1, nil )
    end

    #def busy_handler( db, data=nil, &block )
    #  if block
    #    cb = API::CallbackData.new
    #    cb.proc = block
    #    cb.data = data
    #    result = API.sqlite3_busy_handler( db, API::Sqlite3_ruby_busy_handler, cb )
    #    # Reference the Callback object so that
    #    # it is not deleted by the GC
    #    @busy_handler[db] = cb
    #  else
    #    # Unreference the callback *after* having removed it
    #    # from sqlite
    #    result = API.sqlite3_busy_handler( db, nil, nil )
    #    @busy_handler.delete(db)
    #  end
    #
    #  result
    #end
    #
    #def set_authorizer( db, data=nil, &block )
    #  if block
    #    cb = API::CallbackData.new
    #    cb.proc = block
    #    cb.data = data
    #    result = API.sqlite3_set_authorizer( db, API::Sqlite3_ruby_authorizer, cb )
    #    @authorizer[db] = cb # see comments in busy_handler
    #  else
    #    result = API.sqlite3_set_authorizer( db, nil, nil )
    #    @authorizer.delete(db) # see comments in busy_handler
    #  end
    #
    #  result
    #end
    #
    #def trace( db, data=nil, &block )
    #  if block
    #    cb = API::CallbackData.new
    #    cb.proc = block
    #    cb.data = data
    #    result = API.sqlite3_trace( db, API::Sqlite3_ruby_trace, cb )
    #    @trace[db] = cb # see comments in busy_handler
    #  else
    #    result = API.sqlite3_trace( db, nil, nil )
    #    @trace.delete(db) # see comments in busy_handler
    #  end
    #
    #  result
    #end  

    def create_function( db, name, args, text, cookie, func, step, final )
      if func || ( step && final )
        cb = CallbackData.new
        cb.proc = cb.proc2 = nil
        cb.data = cookie
      end

      if func
        cb.proc = func
        step = final = nil
      elsif step && final
        cb.proc = step
        cb.proc2 = final

        func = nil
      end

      result = CSSQLite.sqlite3_create_function( db, name, args, text, cb, func, step, final )

      # see comments in busy_handler
      if cb
        @callback_data[ name ] = cb
      else
        @callback_data.delete( name )
      end

      return result
    end

    def aggregate_context( context, n = 0)
      CSSQLite.sqlite3_aggregate_context( context, n ).to_a
    end

    def result_text( context, result, utf16=false )
      CSSQLite.sqlite3_result_text( context, result.to_s, -1, nil )
    end

    def self.api_delegate( name )
      eval "def #{name} (*args) ; CSSQLite.sqlite3_#{name}( *args ) ; end"
    end

    api_delegate :errmsg
    api_delegate :libversion
    api_delegate :close
    api_delegate :last_insert_rowid
    api_delegate :changes
    api_delegate :total_changes
    api_delegate :interrupt
    api_delegate :busy_timeout
    api_delegate :errcode
    api_delegate :bind_blob
    api_delegate :bind_double
    api_delegate :bind_int
    api_delegate :bind_int64
    api_delegate :bind_null
    api_delegate :bind_parameter_count
    api_delegate :bind_parameter_name
    api_delegate :bind_parameter_index
    api_delegate :column_count
    api_delegate :step
    api_delegate :data_count
    api_delegate :column_blob
    api_delegate :column_bytes
    api_delegate :column_bytes16
    api_delegate :column_decltype
    api_delegate :column_double
    api_delegate :column_int
    api_delegate :column_int64
    api_delegate :column_name
    api_delegate :column_text
    api_delegate :column_type
    api_delegate :finalize
    api_delegate :reset
    api_delegate :aggregate_count
    api_delegate :value_blob
    api_delegate :value_bytes
    api_delegate :value_bytes16
    api_delegate :value_double
    api_delegate :value_int
    api_delegate :value_int64
    api_delegate :value_text
    api_delegate :value_type
    api_delegate :result_blob
    api_delegate :result_double
    api_delegate :result_error
    api_delegate :result_int
    api_delegate :result_int64
    api_delegate :result_null
    api_delegate :result_value
  end

end ; end ; end
