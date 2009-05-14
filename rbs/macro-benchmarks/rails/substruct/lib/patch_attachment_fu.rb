if RUBY_PLATFORM =~ /win32|mingw/

require 'tempfile'
class Tempfile
 def size
  if @tmpfile
    @tmpfile.fsync # added this line
    @tmpfile.flush
    @tmpfile.stat.size
  else
    0
  end
 end
end

end
