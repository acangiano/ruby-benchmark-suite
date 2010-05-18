require 'substruct_start_and_bootstrap_if_necessary.rb'

# make bigger the app size
GARBAGE = []
30_000_000.times { GARBAGE << 3}

ActionController::RequestProfiler.run(%w[-b -n1 request_root]) # warmup

Bench.run [200] do |n|
  ActionController::RequestProfiler.run(%w[-b -n200 request_root])
end
