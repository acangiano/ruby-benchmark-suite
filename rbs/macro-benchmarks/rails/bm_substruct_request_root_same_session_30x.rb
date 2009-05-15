require 'substruct_start_and_bootstrap_if_necessary.rb'

ActionController::RequestProfiler.run(%w[-b -n1 request_root]) # warmup

Bench.run [100] do
    ActionController::RequestProfiler.run(%w[-b -n1 request_root_15x]) # runs it 2x15 times, one for warmup
end
