string = ""
book = "So Long, and Thanks for All the Fish"
Bench.run [10_000_000] do |n|
  n.times {|i| string << book }
end