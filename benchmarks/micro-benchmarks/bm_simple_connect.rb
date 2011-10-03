require 'socket'

Bench.run [1, 100, 500] do |n|
  server = TCPServer.new '127.0.0.1', 0
  host, port = server.addr[3], server.addr[1]

  n.times do
   client = TCPSocket.new host, port
   server_conn = server.accept
   client.close
   server_conn.close
  end
end
