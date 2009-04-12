def fact(n)
  if (n > 1)
    n * fact(n-1)
  else
    1
  end
end

Bench.run [5000, 10000, 20000] do |n|
  fact(n)
end
