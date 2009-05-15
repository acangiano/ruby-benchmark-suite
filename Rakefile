# This Rakefile is included so you can run RBS Benchmarks
#
# rake bench          # Run all the RBS benchmarks
# rake bench:dir      # Run all the RBS benchmarks in DIR
#      ex: rake bench:dir DIR=rbs/macro-benchmarks
# rake bench:file     # Run only the RBS benchmark specified by FILE
#      ex: rake bench:file FILE=rbs/macro-benchmarks/rails/bm_substruct_one_tenth_startup.rb
# rake bench:results  # Plot the RBS benchmark results (not implemented)
# rake bench:to_csv   # Generate a CSV file of RBS results
#
# NOTE: rakelib/bench.rake requires this directory to be named: benchmark
#       you may want to modify bench.rake to suit your own defaults.
# 	If you want to run a different implementation set the environment
# 	variable VM to point to a ruby executable, or change this line in
# 	rakelib/bench.rake
# 	VM              = ENV['VM'] || "ruby"
#
#       other useful environment variables: ITERATIONS (default 5), TIMEOUT (300)

task :default => :'bench'

