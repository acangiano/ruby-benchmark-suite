require 'substruct_start_and_bootstrap_if_necessary.rb'

ActionController::RequestProfiler.run(%w[-b -n1 request_root]) # warmup

Bench.run [90] do
    ActionController::RequestProfiler.run(%w[-b -n5 request_root_15x]) # runs it 6x15 times, one is for the warmup...
end
