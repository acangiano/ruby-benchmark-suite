require 'find'
require 'fileutils'
require 'lib/bench'

include FileUtils

def create_proc(filename)
  content = File.read(filename)
  eval "lambda { #{content} }"
end

ITERATIONS = 3
TIMEOUT =  90 # seconds for all iterations

main_dir = pwd
benchmarks = []

Find.find(main_dir) do |filename|
  basename = File.basename(filename)
  next if basename !~ /^bm_.+\.rb$/
  label = filename.sub(main_dir, '')
  dirname = File.dirname(filename)
  benchmark = BenchmarkRunner.new(label)
  bench_proc = create_proc(filename)
  cd(dirname) do
    benchmark.run(ITERATIONS, TIMEOUT) do
      bench_proc.call
    end
  end
  benchmarks << benchmark
end

File.open("report.txt", "w") do |f|
  f.puts "Report created on: #{Time.now}"
  f.puts "Version: #{RUBY_VERSION}"
  f.puts "Patchlevel: #{RUBY_PATCHLEVEL}"
  f.puts "Release date: #{RELEASE_DATE}"
  f.puts "Benchmark\tExecution Time\tStandard Deviation"
  benchmarks.sort.each do |benchmark|
    f.puts benchmark
  end
end