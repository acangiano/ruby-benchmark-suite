# Monte Carlo Pi
# Submitted by Seo Sanghyeon

sample = 10_000_000
count = 0

sample.times do
  x = rand
  y = rand
  if x * x + y * y < 1
    count += 1
  end
end

pi = 4.0 * count / sample
puts pi
