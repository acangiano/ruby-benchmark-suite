require 'substruct_start_and_bootstrap_if_necessary.rb'

if Product.count != 2000
  Product.destroy_all
  2000.times { |n|
       Product.create :name => "name", :code => n, :description => "bbc"*1000, :price => 0.5, :date_available => Time.now, :weight => 5
       # faster to insert with raw sql, though not by too much
       # ActiveRecord::Base.connection.execute("insert into items (type, name, code, description, price, weight, date_available) values ('Product', 'name', '#{n}', '#{'b'*500}', 3.0, 5, NOW())")

  }
end

Bench.run [6000] do
  3.times { Product.find(:all) }
end
