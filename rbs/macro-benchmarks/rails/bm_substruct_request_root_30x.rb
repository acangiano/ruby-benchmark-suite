require 'substruct_start_and_bootstrap_if_necessary.rb'

ActionController::RequestProfiler.run(%w[-b -n1 request_root]) # warmup

Bench.run [100] do
    ActionController::RequestProfiler.run(%w[-b -n30 request_root])
end
