require File.dirname(__FILE__) + '/../lib/benchutils'

label = File.expand_path(__FILE__).sub(File.expand_path("..") + "/", "")
iterations = ARGV[-3].to_i
timeout = ARGV[-2].to_i
report = ARGV.last

require 'substruct_start_and_bootstrap_if_necessary.rb'
ActiveRecord::Base.connection.execute("delete from items where type = 'Variation'")

if Product.count == 0
 Product.create :name => 'prod1', :code => 'code1'
end

product = Product.first

  benchmark = BenchmarkRunner.new(label, iterations, timeout)
  benchmark.run do
  100.times { |n|
       Variation.create :name => "name", :code => n, :description => "bbc"*1000, :price => 0.5, :date_available => Time.now, :weight => 5, :product => product
}
  end
  File.open(report, "a") {|f| f.puts "#{benchmark.to_s},n/a" }
