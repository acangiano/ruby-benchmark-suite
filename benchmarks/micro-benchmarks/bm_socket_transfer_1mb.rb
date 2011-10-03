require 'socket'

def write_meg(block_size)
  server_socket = TCPServer.new '127.0.0.1', 0
  client = TCPSocket.new server_socket.addr[3], server_socket.addr[1]
  server = server_socket.accept
  receiver = Thread.new {
    loop { 
      got = server.recv 10 
      break if got.length == 0 # closed socket
    }  
  }
  string = 'a'*block_size
  (1000000/block_size).times {
    client.write string
  }
  client.close
  receiver.join
end 

Bench.run [10000, 1000000] do |n|
  write_meg(n)
end
