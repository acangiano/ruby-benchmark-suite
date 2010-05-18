require 'substruct_start_and_bootstrap_if_necessary.rb'

ActionController::RequestProfiler.run(%w[-b -n1 request_root]) # warmup

Bench.run [90] do
    ActionController::RequestProfiler.run(%w[-b -n90 request_root])
end
