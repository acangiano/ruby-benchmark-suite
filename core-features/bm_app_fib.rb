def fib(n)
  if n < 2
    n
  else
    fib(n-1) + fib(n-2)
  end
end

35.times {|n| puts fib(n) }

