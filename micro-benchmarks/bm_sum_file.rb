# Adapted for the Ruby Benchmark Suite.

100.times do
  count = 0
  File.open("random.input", "r").each_line do |line|
    count += line.to_i
  end
  puts count
end