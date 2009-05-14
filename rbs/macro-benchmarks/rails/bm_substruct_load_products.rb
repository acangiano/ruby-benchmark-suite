require File.dirname(__FILE__) + '/../lib/benchutils'

label = File.expand_path(__FILE__).sub(File.expand_path("..") + "/", "")
iterations = ARGV[-3].to_i
timeout = ARGV[-2].to_i
report = ARGV.last

require 'substruct_start_and_bootstrap_if_necessary.rb'

if Product.count != 2000
  Product.destroy_all
  2000.times { |n|
       # Product.create :name => "name", :code => n, :description => "bbc"*1000, :price => 0.5, :date_available => Time.now, :weight => 5

       # faster to insert with raw sql, though not by too much
       ActiveRecord::Base.connection.execute("insert into items (type, name, code, description, price, weight, date_available) values ('Product', 'name', '#{n}', '#{'b'*500}', 3.0, 5, NOW())")

  }
end

  benchmark = BenchmarkRunner.new(label, iterations, timeout)
  benchmark.run do
    3.times { Product.find(:all) }
  end
  File.open(report, "a") {|f| f.puts "#{benchmark.to_s},n/a" }
