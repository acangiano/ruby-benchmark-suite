#!/usr/bin/env ruby
#
# adapted from http://www.shelldorado.com/scripts/cmds/timeout
# Converted to Ruby by Monty Williams, April 2009
#
# Starts a "watchdog" process, then execs a command
# The "watchdog" sleeps for -t seconds then kills this process
# This depends on 'exec' starting a process that retains this process' pid
#   On some OS's (e.g. Windows) exec doesn't work that way. Here's a test:
#     ruby -e "pid1=$$;puts pid1;exec'ruby -e \"pid2=$$;puts pid2\"'"
#   The above should return two identical PIDs
#   If it doesn't this program won't work
#
# Antonio suggested this might yield an answer
#   http://whynotwiki.com/Ruby_/_Process_management 

prog = File.dirname(__FILE__) + "/timeout.rb"
prog_name  = File.basename(prog)		# Program name
version = 0.1
time_out = 10					# Set default [seconds]

if ARGV.length == 0
	puts "#{prog_name} - set timeout for a command, version #{version}"
	puts "Usage: #{prog_name} [-t timeout] command [argument ...]"
	puts "-t: timeout (in seconds, default is #{time_out})"
	exit 0
end

if ARGV.first == '-t'
	ARGV.shift
	time_out = ARGV.first
	ARGV.shift
end

if ARGV.first == '-p'
	ARGV.shift
	parent_pid = ARGV.first
	ARGV.shift
end

if parent_pid
	# Sleep and then kill our parent process
	# puts "DEBUG: Sleep for #{time_out} seconds and then kill pid #{parent_pid}"
	sleep time_out.to_i
	# puts "DEBUG: Finished sleeping"        
	begin
                [:TERM, :HUP, :KILL].each do |sig|
                  begin
                    Process.kill(sig, parent_pid.to_i)
                    sleep 2
                  rescue Errno::EINVAL, ArgumentError => e
                    next
                  end
                end
	rescue Errno::ESRCH => e
		# puts "DEBUG: rescue #{e.class}: #{e.message}"
		nil
	end
else
	# Start "watchdog" process, and then run the command.
	# puts "DEBUG: Watchdog invocation is #{watchdog}"
	# puts "DEBUG: Start watchdog process to kill pid #{$$} and then run:"
        # puts "DEBUG: #{ARGV.join(' ')}"
        io = IO.popen("#{ARGV.join(' ')}")
	watchdog = "ruby #{prog} -t #{time_out} -p #{io.pid}" 
	system("#{watchdog}")			# Start watchdog
end
