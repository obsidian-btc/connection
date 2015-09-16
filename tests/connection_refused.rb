require_relative "./tests_init"

class Client
  attr_reader :connection

  def self.build(port)
    connection = Connection::Client.build "127.0.0.1", port
    new connection
  end

  def initialize(connection)
    @connection = connection
  end

  def start
    logger.trace "Sending ping"
    connection.puts "ping" 
    logger.trace "Receiving response"
    connection.gets
  end

  def change_connection_policy(policy)
    connection.policy = policy
  end
end

class Server
  attr_reader :delay_before_start
  attr_reader :server_connection

  def self.build(port, delay_before_start = nil)
    delay_before_start ||= 0.2
    server_connection = Connection::Server.build "127.0.0.1", port
    new server_connection, delay_before_start
  end

  def initialize(server_connection, delay_before_start)
    @delay_before_start = delay_before_start
    @server_connection = server_connection
  end

  def start
    logger.trace "Accepting connection"
    server_connection.accept do |client|
      logger.trace "Receiving request"
      request = client.gets
      logger.trace "Sending response"
      client.puts "PONG"
    end
  end

  def change_connection_policy(policy)
    server_connection.policy = policy
  end
end

describe "Immediate connections" do
  next
  response = nil

  Connection::Policy::Immediate.retry_interval = 0.05

  client_thread = Thread.new do
    Thread.current.abort_on_exception = true
    client = Client.build 9990
    response = client.run
  end

  server = Server.build 9990
  server.run
  client_thread.join

  assert response, :equals => "PONG\n"
end

describe "Cooperative connections" do
  reactor = Connection::Reactor.build

  server = Server.build 9991
  client = Client.build 9991
  reactor.register client
  reactor.register server

  reactor.run
end
