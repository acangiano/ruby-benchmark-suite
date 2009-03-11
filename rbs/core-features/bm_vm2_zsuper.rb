class C
  def m(a)
    1
  end
end

class CC < C
  def m(a)
    super
  end
end

Bench.run [1_000_000, 2_000_000, 4_000_000, 8_000_000] do |n|
  obj = CC.new
  n.times { obj.m(10) }
end
