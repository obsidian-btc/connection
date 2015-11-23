require_relative './server_spec_init'

describe 'Server Connection' do
  specify 'Accepting Connections' do
    tcp_server = TCPServer.new 2000
    server = Connection::Server.new tcp_server
    client_to_server_socket = TCPSocket.new '127.0.0.1', 2000

    server_to_client_connection = server.accept

    client_to_server_socket.write 'some-message'
    data = server_to_client_connection.read
    assert data, :equals => 'some-message'
  end

  describe 'Stats' do
    specify 'Bytes Sent/Received'
    specify 'Total Connections'
  end
end
