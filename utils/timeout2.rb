# used just for windows currently

if(ARGV[0] != '-t')
 puts "format: -t secs, command arg1 arg2..."
 exit
end

require 'timeout'
out = nil
begin
  Timeout::timeout(ARGV[1].to_f) {
    out = IO.popen ARGV[2..-1].join(' ')
    while !out.eof?
      puts out.read 1024
    end      
    Process.wait out.pid
  }
rescue Timeout::Error
  puts 'timed out'
  Process.kill "KILL", out.pid # if this fails it may have died right then
end
