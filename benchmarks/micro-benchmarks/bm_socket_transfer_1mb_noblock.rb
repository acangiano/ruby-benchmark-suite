require 'socket'

def write_meg(block_size)
  server = TCPServer.new '127.0.0.1', 0
  client = TCPSocket.new server.addr[3], server.addr[1]
  server = server.accept
  receiver = Thread.new do
    loop do
      got = server.recv 10 
      break if got.length == 0 # closed socket
    end
  end

  string = 'a' * block_size
  (1000000/block_size).times do
    sent = 0
    begin
      result = client.write_nonblock(string[0..(block_size - sent)])
      sent += result

      raise Errno::EAGAIN if sent < block_size
    rescue Errno::EAGAIN, Errno::EWOULDBLOCK, Errno::EINTR
      puts 'retry'
      IO.select(nil, [client])
      retry
    end
  end
  client.close
  receiver.join
end

Bench.run [10000, 1000000] do |n|
  write_meg(n)
end
