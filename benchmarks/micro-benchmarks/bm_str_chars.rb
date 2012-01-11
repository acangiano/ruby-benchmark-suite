# That ruby code is gonna show you that the Ruby version 1.9.3 manage strings in a different way. 
# If you have one string with 23 or less characteres, it would be a way faster than a string with 24 or more.
# All the credits to Pat Shaughnessy, http://patshaughnessy.net/2012/1/4/never-create-ruby-strings-longer-than-23-characters
# DON'T FORGET TO CHANGE THE RUBY VERSION TO 1.9.3 Ex:RVM $ rvm use 1.9.3

require 'benchmark'

ITERATIONS = 2000000

def run(str, bench)
  bench.report("#{str.length + 1} chars") do
    ITERATIONS.times do
      new_string = str + 'x'
    end
  end
end

Benchmark.bm do |bench|
  run("01234567890123456789", bench)
  run("012345678901234567890", bench)
  run("0123456789012345678901", bench)
  run("01234567890123456789012", bench)
  run("012345678901234567890123", bench)
  run("0123456789012345678901234", bench)
end