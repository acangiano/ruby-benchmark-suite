# This script provides a place to insert a potentially platform-specific
# method of monitoring a benchmark and possibly aborting the run if it
# exceeds a specified time limit. See README for more details.

timeout = File.dirname(__FILE__) + "/timeout"

null = "/dev/null"

require 'rbconfig'
if RbConfig::CONFIG['host_os'] =~ /mswin|mingw/ # jruby compat.
  timeout = "ruby " + File.dirname(__FILE__) + "/timeout2.rb"
  null = "NUL"
end

limit, vm, runner, name, iterations, report, meter_memory = ARGV

cmd = "#{timeout} -t #{limit} #{vm} #{runner} #{name} #{iterations} #{report} #{meter_memory}"

if ENV['VERBOSE']
  puts cmd
else
  cmd += " >#{null}"
end

start = Time.now
system cmd
finish = Time.now

unless $?.success?
  File.open report, "a" do |f|
    f.puts "---"
    f.puts "name: #{name}"

    timed_out = (finish - start) * 100.0 / limit.to_i > 95

    if timed_out
      f.puts "status: Timeout"
    else
      begin
        signaled =  $?.signaled?
      rescue Exception
        # $? doesn't respond to $? in jruby, so we'll end up here
      end
      if signaled
        f.puts "status: Terminated SIG#{Signal.list.invert[$?.termsig]}"
      else
        f.puts "status: Terminated for unknown reason"
      end
    end
  end
end
