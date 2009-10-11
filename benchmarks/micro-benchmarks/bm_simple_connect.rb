require 'socket'

Bench.run [1, 100, 500] do |n|
  server = TCPServer.new ''
  port = server.addr[1]

  n.times do
   client = TCPSocket.new 'localhost', port
   server_conn = server.accept
   client.close
   server_conn.close
  end
end
