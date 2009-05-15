# This just reports the amount of time it took to load rails for a substruct run through.
# Note that if you've never "initialized" the database this will do so, so will take longer and be a poor test.
# Currently we can only "startup" once, too, so your results will very much be skewed the first time you run it.
# unfortunately there's no easy way to load the startup multiple times and have it work on windows, too
# But still a useful metric

  start = Time.now
  require 'substruct_start_and_bootstrap_if_necessary.rb'
  time_first_time_through_time = Time.now - start
  Bench.run do
      sleep time_first_time_through_time/10
  end
