ENV['PLUGIN'] = 'substruct' # must be set early
ENV['RAILS_ENV'] = 'test' # use this database

DROP_DB_EACH_TIME = true
require 'substruct_start_and_bootstrap_if_necessary.rb'

start = Time.now
begin
   Rake::Task['test:plugins:all'].invoke
rescue RuntimeError => e
   raise unless e.to_s =~ /Command failed with status/ # this is ok
end
total_time = Time.now - start

Bench.run [0.1] do
 sleep total_time/10 # ughly, but cross platform
end
