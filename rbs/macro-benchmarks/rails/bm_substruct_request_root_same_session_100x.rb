require File.dirname(__FILE__) + '/../lib/benchutils'

label = File.expand_path(__FILE__).sub(File.expand_path("..") + "/", "")
iterations = ARGV[-3].to_i
timeout = ARGV[-2].to_i
report = ARGV.last

require 'substruct_start_and_bootstrap_if_necessary.rb'
require 'config/environment'
require 'application'
require 'action_controller/request_profiler'

  benchmark = BenchmarkRunner.new(label, iterations, timeout)
  benchmark.run do
    ActionController::RequestProfiler.run(%w[-b -n1 request_root_100x])
  end
  File.open(report, "a") {|f| f.puts "#{benchmark.to_s},n/a" }
