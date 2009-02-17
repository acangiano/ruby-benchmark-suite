# Note that it uses 400MB of RAM, but doesn't run as many iterations since that makes for a very slow test
# on MRI, at least
require File.dirname(__FILE__) + '/../lib/benchutils'
label = File.expand_path(__FILE__).sub(File.expand_path("..") + "/", "")

iterations = ARGV[-3].to_i
timeout = ARGV[-2].to_i
report = ARGV.last


# start test:

  benchmark = BenchmarkRunner.new(label, iterations, timeout)
  benchmark.run do
    a = []
    3000000.times { a << []} # use up some RAM
    100000.times {[]}
  end
  
  File.open(report, "a") {|f| f.puts "#{benchmark.to_s},n/a" }
