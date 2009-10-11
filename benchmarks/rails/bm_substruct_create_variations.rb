require './substruct_start_and_bootstrap_if_necessary.rb'
ActiveRecord::Base.connection.execute("delete from items where type = 'Variation'")

if Product.count == 0
 Product.create :name => 'prod1', :code => 'code1'
end

product = Product.first

Bench.run [100] do
  100.times { |n|
       Variation.create :name => "name", :code => n, :description => "bbc"*1000, :price => 0.5, :date_available => Time.now, :weight => 5, :product => product
}
end
