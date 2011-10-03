require 'socket'

Bench.run [1, 100, 100000] do |n|
  server = TCPServer.new '127.0.0.1', 0
  client = TCPSocket.new server.addr[3], server.addr[1]
  server_conn = server.accept
  n.times do
    client.write 'a'
    server_conn.recv 1024 # 'a'
  end
end
