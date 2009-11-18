if(ARGV[0] != '-t')
 puts "format: -t secs, command arg1 arg2..."
 exit
end

require 'timeout'
begin
  Timeout::timeout(ARGV[1].to_i) {
    system(ARGV[2..-1].join(' '))
  }
rescue Timeout::Error
  puts 'timed out'
end
