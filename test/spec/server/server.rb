require_relative './server_spec_init'

describe 'Server Connection' do
  specify 'Accepting Connections' do
    tcp_server = TCPServer.new 2000
    server = Connection::Server.new tcp_server
    client_to_server_socket = TCPSocket.new '127.0.0.1', 2000

    begin
      server_to_client_connection = server.accept

      client_to_server_socket.write 'some-message'
      data = server_to_client_connection.read
      assert data, :equals => 'some-message'
    ensure
      tcp_server.close unless tcp_server.closed?
      client_to_server_socket.close unless client_to_server_socket.closed?
    end
  end

  specify 'Error During OpenSSL Handshaking' do
    Connection::Controls::SSL.pair do |server, client|
      client.to_io.close
      connection = server.accept
      assert connection.nil?
    end
  end
end
