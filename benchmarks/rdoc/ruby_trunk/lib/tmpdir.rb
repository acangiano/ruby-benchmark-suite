#
# tmpdir - retrieve temporary directory path
#
# $Id: tmpdir.rb 25720 2009-11-11 10:17:36Z nobu $
#

require 'fileutils'

class Dir

  @@systmpdir = '/tmp'

  if /mswin|mingw|cygwin/ =~ RUBY_PLATFORM and
      begin
        require 'Win32API'
        true
      rescue LoadError
      end
    CSIDL_LOCAL_APPDATA = 0x001c
    max_pathlen = 260
    windir = "\0"*(max_pathlen+1)
    begin
      getdir = Win32API.new('shell32', 'SHGetFolderPath', 'LLLLP', 'L')
      raise RuntimeError if getdir.call(0, CSIDL_LOCAL_APPDATA, 0, 0, windir) != 0
      windir.rstrip!
    rescue RuntimeError
      begin
        getdir = Win32API.new('kernel32', 'GetSystemWindowsDirectory', 'PL', 'L')
      rescue RuntimeError
        getdir = Win32API.new('kernel32', 'GetWindowsDirectory', 'PL', 'L')
      end
      windir[getdir.call(windir, windir.size)..-1] = ""
    end
    windir.force_encoding(Dir.pwd.encoding)
    temp = File.expand_path('temp', windir.untaint)
    @@systmpdir = temp if File.directory?(temp) and File.writable?(temp)
  end

  ##
  # Returns the operating system's temporary file path.

  def Dir::tmpdir
    tmp = '.'
    if $SAFE > 0
      tmp = @@systmpdir
    else
      for dir in [ENV['TMPDIR'], ENV['TMP'], ENV['TEMP'], @@systmpdir, '/tmp']
	if dir and stat = File.stat(dir) and stat.directory? and stat.writable?
	  tmp = dir
	  break
	end rescue nil
      end
      File.expand_path(tmp)
    end
  end

  # Dir.mktmpdir creates a temporary directory.
  #
  # The directory is created with 0700 permission.
  #
  # The prefix and suffix of the name of the directory is specified by
  # the optional first argument, <i>prefix_suffix</i>.
  # - If it is not specified or nil, "d" is used as the prefix and no suffix is used.
  # - If it is a string, it is used as the prefix and no suffix is used.
  # - If it is an array, first element is used as the prefix and second element is used as a suffix.
  #
  #  Dir.mktmpdir {|dir| dir is ".../d..." }
  #  Dir.mktmpdir("foo") {|dir| dir is ".../foo..." }
  #  Dir.mktmpdir(["foo", "bar"]) {|dir| dir is ".../foo...bar" }
  #
  # The directory is created under Dir.tmpdir or
  # the optional second argument <i>tmpdir</i> if non-nil value is given.
  #
  #  Dir.mktmpdir {|dir| dir is "#{Dir.tmpdir}/d..." }
  #  Dir.mktmpdir(nil, "/var/tmp") {|dir| dir is "/var/tmp/d..." }
  #
  # If a block is given,
  # it is yielded with the path of the directory.
  # The directory and its contents are removed
  # using FileUtils.remove_entry_secure before Dir.mktmpdir returns.
  # The value of the block is returned.
  #
  #  Dir.mktmpdir {|dir|
  #    # use the directory...
  #    open("#{dir}/foo", "w") { ... }
  #  }
  #
  # If a block is not given,
  # The path of the directory is returned.
  # In this case, Dir.mktmpdir doesn't remove the directory.
  #
  #  dir = Dir.mktmpdir
  #  begin
  #    # use the directory...
  #    open("#{dir}/foo", "w") { ... }
  #  ensure
  #    # remove the directory.
  #    FileUtils.remove_entry_secure dir
  #  end
  #
  def Dir.mktmpdir(prefix_suffix=nil, *rest)
    path = Tmpname.create(prefix_suffix || "d", *rest) {|n| mkdir(n, 0700)}
    if block_given?
      begin
        yield path
      ensure
        FileUtils.remove_entry_secure path
      end
    else
      path
    end
  end

  module Tmpname # :nodoc:
    module_function

    def tmpdir
      Dir.tmpdir
    end

    def make_tmpname(prefix_suffix, n)
      case prefix_suffix
      when String
        prefix = prefix_suffix
        suffix = ""
      when Array
        prefix = prefix_suffix[0]
        suffix = prefix_suffix[1]
      else
        raise ArgumentError, "unexpected prefix_suffix: #{prefix_suffix.inspect}"
      end
      t = Time.now.strftime("%Y%m%d")
      path = "#{prefix}#{t}-#{$$}-#{rand(0x100000000).to_s(36)}"
      path << "-#{n}" if n
      path << suffix
    end

    def create(basename, *rest)
      if opts = Hash.try_convert(rest[-1])
        opts = opts.dup if rest.pop.equal?(opts)
        max_try = opts.delete(:max_try)
        opts = [opts]
      else
        opts = []
      end
      tmpdir, = *rest
      if $SAFE > 0 and tmpdir.tainted?
        tmpdir = '/tmp'
      else
        tmpdir ||= tmpdir()
      end
      n = nil
      begin
        path = File.expand_path(make_tmpname(basename, n), tmpdir)
        yield(path, n, *opts)
      rescue Errno::EEXIST
        n ||= 0
        n += 1
        retry if !max_try or n < max_try
        raise "cannot generate temporary name using `#{basename}' under `#{tmpdir}'"
      end
      path
    end
  end
end
