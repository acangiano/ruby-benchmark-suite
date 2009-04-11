require File.dirname(__FILE__) + '/../lib/benchutils'

label = File.expand_path(__FILE__).sub(File.expand_path("..") + "/", "")
iterations = ARGV[-3].to_i
timeout = ARGV[-2].to_i
report = ARGV.last

def m(&b)
  b
end

input_sizes = [1_000_000, 2_000_000, 4_000_000, 8_000_000]

input_sizes.each do |n|
  benchmark = BenchmarkRunner.new(label, iterations, timeout)
  benchmark.run do
    pr = m { a = 1 }
    n.times do |i|
      pr.call
    end
  end
  
  File.open(report, "a") {|f| f.puts "#{benchmark.to_s},#{n}" }
end
