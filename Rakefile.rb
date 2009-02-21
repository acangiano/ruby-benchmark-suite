require 'lib/benchutils'

#--------------------------------
# Benchmark Configuration
#--------------------------------

# The RUBY_VM value can include arguments: e.g. rake RUBY_VM="jruby1.0 -J-server"
RUBY_VM = ENV['RUBY_VM'] || "ruby"

# TIMEOUT is the maximum amount of time allocated for a set of iterations.
# For example, if TIMEOUT is 300 and ITERATIONS is 5, then each iteration
# can take up to a maxium of 60 seconds to complete.
# If multiple input sizes are being tested in a benchmark,
# they'll each be allocated this amount of time in seconds (before timing out).
TIMEOUT =  (ENV['TIMEOUT'] || -1).to_i

ITERATIONS = (ENV['ITERATIONS'] || 5).to_i
VERBOSE = ENV['VERBOSE']
report = "#{Time.now.strftime("%Y%m%d%H%M%S")}_#{RUBY_VM.gsub('/','').gsub('\\', '').gsub(':', '').split.first}.csv"
REPORT = ENV['REPORT'] || report

MAIN_DIR = pwd
         
#--------------------------------
# Rake Tasks
#--------------------------------

# a friendly output on -T or --tasks
if(ARGV.include?("-T") || ARGV.include?("--tasks"))
 puts "Optional options: [ITERATIONS=3] [RUBY_VM=\"/path/to/ruby opts\"] [TIMEOUT=secs -- causes ruby to run a surrounding thread timing out the operation] [REPORT=outputfile] [VERBOSE=1 outputs the output of tests]"
end

task :default => [:run_all]

desc "Initializes report; Used by the others."
task :report do
  File.open(REPORT, "w") do |f|
    f.puts "Report created on: #{Time.now}"
    begin
      version_string = `#{RUBY_VM} -v`.chomp
      version_string = `#{RUBY_VM} -v -e \"require 'rbconfig'; print Config::CONFIG['CFLAGS']\"`.gsub("\n", ";").strip
    rescue Exception
    end
    f.puts "Ruby VM: #{RUBY_VM} [#{version_string}]"
    f.puts "Iterations: #{ITERATIONS}"
    f.puts
    times_header = ''
    ITERATIONS.times {|i| times_header << "Time ##{i+1},"  }
    # assume that you can get rss, for now
    rss_header = ''
    ITERATIONS.times {|i| rss_header << "RSS ##{i+1},"  }
    header = "Benchmark Name,#{times_header}Avg Time,Std Dev,Input Size,#{rss_header}"
    f.puts header
  end
end

desc "Runs a single benchmark; specify as FILE=micro-benchmarks/bm_mergesort.rb"
task :run_one => :report do
  benchmark = ENV['FILE']
  puts 'ERROR: need to specify file, a la FILE="micro-benchmarks/bm_mergesort.rb"' unless benchmark
  basename = File.basename(benchmark)    
  puts "ERROR: non bm_ file specified" if basename !~ /^bm_.+\.rb$/
  puts "Report will be written to #{REPORT}"
  process_file benchmark
  puts "Report written in #{REPORT}"
end

desc "Runs a directory worth of benchmarks; specify as DIR=micro-benchmarks"
task :run_dir => :report do
  dir = ENV['DIR']
  puts 'ERROR: need to specify directory, a la DIR="micro-benchmarks/bm_mergesort.rb"' unless dir
  puts "Report will be written to #{REPORT}"
  all_files = []
  Find.find('./' + dir) do |filename|
    all_files << filename
  end

  all_files.sort.each{|filename|
    process_file filename
  }
  puts "Report written in #{REPORT}"
end

desc "Default. Runs all the benchmarks in the suite."
task :run_all => :report do
  puts "Ruby Benchmark Suite started"
  puts "-------------------------------"
  puts "Report will be written to #{REPORT}"
  puts "Benchmarking startup time"
  benchmark_startup
  all_files = []
  Find.find(MAIN_DIR) do |filename|
    all_files << filename
  end

  all_files.sort.each do |filename|
	process_file filename
  end
  puts "-------------------------------"
  puts "Ruby Benchmark Suite completed"
  puts "Report written in #{REPORT}"
end

private

def process_file filename
  basename = File.basename(filename)
  return if basename !~ /^bm_.+\.rb$/  
  dirname = File.dirname(filename)
  cd(dirname) do
    puts "Benchmarking #{filename}"
    if(VERBOSE)
      system("#{RUBY_VM} #{basename} #{ITERATIONS} #{TIMEOUT} #{MAIN_DIR}/#{REPORT}")
    else
      `#{RUBY_VM} #{basename} #{ITERATIONS} #{TIMEOUT} #{MAIN_DIR}/#{REPORT}`
    end
  end

end


def benchmark_startup
  benchmark = BenchmarkRunner.new("Startup", ITERATIONS, TIMEOUT)
  benchmark.run do
    `#{RUBY_VM} core-features/startup.rb`
  end

  File.open(REPORT, "a") do |f|
    f.puts "#{benchmark.to_s},n/a"
  end
end

