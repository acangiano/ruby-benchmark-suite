# Bench is a simple benchmarking harness that provides a single
# method to be used by the benchmark file. The benchmark file
# is expected to call Bench.run with a block in which the actual
# work of the benchmark is performed. For example,
#
#   # bm_quirksome.rb
#   def quirks
#     # do something interesting
#   end
#
#   Bench.run [100] { |n| quirks n }
#
# Bench.run will run the blocktime the running of the block for the requested
# number of iterations and then compute some statistics and append
# a YAML-formatted report to the specified file.
class Bench
  attr_accessor :parameter
  attr_reader   :times, :memory_readings, :sorted, :file, :name, :n, :report, :meter_memory

  def initialize(name, n, report, meter_memory)

    @name   = name
    @file   = File.basename name
    @n      = n.to_i
    @report = report
    @meter_memory = meter_memory == 'yes' # default is yes
    reset
    self.class.register self
  end

  def self.register(instance)
    @bench = instance
  end

  def self.bench
    @bench
  end

  def self.run(parameters, &block)
    bench.run(parameters, &block)
  end

  def reset
    @times = []
    @memory_readings = []
    @mean  = nil
  end

  def run(inputs)
    parameterized inputs do |input|
      n.times do
        start = Time.now

        yield input

        finish = Time.now
        times << finish - start
        if @meter_memory
          begin
            # attempt to do this in a jruby friendly way
            require 'rbconfig'
            if RbConfig::CONFIG['host_os'] =~ /mingw|mswin/
              # windows
              if RUBY_PLATFORM =~ /java/
               require 'java'
               mem_bean = java.lang.management.ManagementFactory.memory_mxbean
               memory_used = mem_bean.heap_memory_usage.used + mem_bean.non_heap_memory_usage.used
              else
                require 'win32ole'
                wmi = WIN32OLE.connect("winmgmts://")
                processes = wmi.ExecQuery("select * from win32_process where ProcessId = #{Process.pid}")
                memory_used = nil
                for process in processes; memory_used = process.WorkingSetSize; end
              end
            else
              kb = `ps -o rss= -p #{Process.pid}`.to_i # in kilobytes
              memory_used = kb*1024
            end
            memory_readings << memory_used
          rescue Exception => e
            memory_readings << e
          end
        end

      end
    end
  end

  def parameterized(inputs)
    write_parameters inputs

    inputs.each do |input|
      reset
      self.parameter = input

      yield input

      @sorted = times.sort # sorted is used internally for collecting stats
      write_report
    end
  end

  def write_parameters(inputs)
    File.open report, "a" do |f|
      f.puts "---"
      f.puts "name: #{name}"
      f.puts "parameters:"
      inputs.each do |input|
        f.puts "- #{input}"
      end

      begin
        version_string = ""
        version_string = "#{RUBY_VERSION} #{RUBY_RELEASE_DATE} #{RUBY_PATCHLEVEL} #{RUBY_PLATFORM}"
        require 'rbconfig'
        version_string += ';' + Config::CONFIG['CFLAGS'] + ';' + Config::CONFIG["configure_args"]
      rescue Exception
      end

      f.puts "ruby_ver: " + version_string
    end
  end

  def write_report
    File.open report, "a" do |f|
      f.puts "---"
      f.puts "name: #{name}"
      f.puts "parameter: #{parameter}"
      f.puts "iterations: #{n}"
      f.puts "max: #{max}"
      f.puts "min: #{min}"
      f.puts "median: #{median}"
      f.puts "mean: #{mean}"
      f.puts "standard_deviation: #{standard_deviation}"
      f.puts "times:"
      times.each { |t| f.puts "- #{t}" }
      if @meter_memory
        f.puts "memory_usages:"
        memory_readings.each{|m| f.puts "- #{m}" }
      end
    end
  end

  # written after the report, meaning none of the tests resulted in an Exception, and all of them finished
  def write_success
    File.open report, "a" do |f|
      f.puts "---"
      f.puts "name: #{name}"
      f.puts "status: success"
    end
  end

  def write_error(exc)
    File.open report, "a" do |f|
      f.puts "---"
      f.puts "name: #{name}"
      f.puts "parameter: #{parameter}"
      status = "#{exc.class} #{exc.message} #{exc.backtrace[0]}"
      f.puts "status: #{status.inspect}"
    end
  end

  def max
    sorted.last
  end

  def min
    sorted.first
  end

  def mean
    @mean ||= times.inject(0) { |sum, t| sum + t } / n
  end

  def median
    sorted[n / 2]
  end

  def standard_deviation
    Math.sqrt(times.inject(0) { |sum, t| sum + (mean - t) ** 2 } / n)
  end

  # Perhaps this should be configurable. Generally, it doesn't make
  # sense for benchmark files to be puts'ing stuff unless it is benching
  # #puts. Validate the correctness of the benchmark independently.
  def puts(*args)
  end
end

# Run the benchmark
begin
  bench = Bench.new(*ARGV)
  load bench.file
  bench.write_success
rescue Object => exc
  bench.write_error exc if bench
  exit 1
end
