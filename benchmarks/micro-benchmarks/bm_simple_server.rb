require 'socket'

Bench.run [1, 100, 100000] do |n|
  server = TCPServer.new ''
  port = server.addr[1]
  client = TCPSocket.new 'localhost', port
  server_conn = server.accept
  n.times do
    client.write 'a'
    server_conn.recv 1024 # 'a'
  end
end
