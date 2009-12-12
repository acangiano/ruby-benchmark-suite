begin
  require 'ffi'
rescue LoadError
  require 'rubygems' # this for MRI 1.8
  # of course, it's then not quite as fair a test, but reasonably close
  require 'ffi'
end

module Hello
  extend FFI::Library
  # require right lib
  require 'rbconfig'
  if RbConfig::CONFIG['host_os'] =~ /mswin|mingw/
    ffi_lib 'msvcrt'
  else
    ffi_lib 'libc.so.6' # linux
  end
  attach_function 'printf', [:string, :varargs], :int

end


Bench.run [100000] do |n|
  n.times do
   Hello.printf("%s%s%s", :string, "", :string, "", :string, "")
  end
end
