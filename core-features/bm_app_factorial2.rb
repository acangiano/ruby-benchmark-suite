# Reduced version for MRI

def fact(n)
  if(n > 1)
    n * fact(n-1)
  else
    1
  end
end

5.times do 
  puts fact(3000)
end