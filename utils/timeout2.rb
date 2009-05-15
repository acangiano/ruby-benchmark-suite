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

=begin
doctest: should terminate immediately after the sub command does:
 start_time = Time.now
 system("ruby timeout2.rb -t 3 ruby -v")
 Time.now - start_time < 3
=> true

doctest: should timeout a longer running command
 start_time = Time.now
 system("ruby timeout2.rb -t 3 ruby -e 'sleep 10'")
 puts (Time.now - start_time) # around 3
 (Time.now - start_time) < 5

=> true

=end
