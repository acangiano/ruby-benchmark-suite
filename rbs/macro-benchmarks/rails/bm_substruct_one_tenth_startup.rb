# This just reports the amount of time it took to load rails for a substruct run through.
# Note that if you've never "initialized" the database this will do so, so will take longer.
# Currently it can only "startup" once, too, so your results will be skewed the first time you run it.

require File.dirname(__FILE__) + '/../lib/benchutils'

label = File.expand_path(__FILE__).sub(File.expand_path("..") + "/", "")
iterations = ARGV[-3].to_i
timeout = ARGV[-2].to_i
report = ARGV.last

# For some benchmarks it doesn't even make sense to have variable input sizes.
# If this is the case, feel free to remove the outer block that iterates over the array.
  benchmark = BenchmarkRunner.new(label, iterations, timeout)
  # unfortunately there's no easy way to load the startup multiple times and have it work on windows, too
  start = Time.now
  require 'substruct_start_and_bootstrap_if_necessary.rb'
  first_time_through_time = Time.now - start
  benchmark.run do
      sleep first_time_through_time/10
  end
  File.open(report, "a") {|f| f.puts "#{benchmark.to_s},n/a" }
