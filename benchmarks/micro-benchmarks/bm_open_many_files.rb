fname = File.dirname(__FILE__) + "/random.input"
Bench.run [50000] do |n|
  n.times { 
    f = File.open(fname, "r")
    f.close
  }
end
