# This script provides a place to insert a potentially platform-specific
# method of monitoring a benchmark and possibly aborting the run if it
# exceeds a specified time limit. See README for more details.

timeout = File.dirname(__FILE__) + "/timeout"

null = "/dev/null"
if RUBY_PLATFORM =~ /mingw|mswin/
  timeout = "ruby " + File.dirname(__FILE__) + "/timeout2.rb"
  null = "NUL"
end

limit, vm, runner, name, iterations, report, meter_memory = ARGV

start = Time.now
cmd = "#{timeout} -t #{limit} #{vm} #{runner} #{name} #{iterations} #{report} #{meter_memory}"
cmd += " >#{null}" unless ENV['VERBOSE']
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
      if $?.signaled?
        f.puts "status: Terminated SIG#{Signal.list.invert[$?.termsig]}"
      else
        f.puts "status: Terminated for unknown reason"
      end
    end
  end
end
