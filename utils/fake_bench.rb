require 'benchmark'

class Bench
 def self.run(settings)
   settings.each {|n| puts n; puts Benchmark.realtime{yield(n)}}
 end
end