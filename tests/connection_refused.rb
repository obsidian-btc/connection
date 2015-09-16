require_relative "./tests_init"

class Client
  attr_reader :port

  def initialize(port)
    @port = port
  end

  def run(&blk)
    connection = Connection::Client.build "127.0.0.1", port
    blk.(connection) if block_given?

    logger.trace "Sending ping"
    connection.puts "ping" 
    logger.trace "Receiving response"
    connection.gets
  end
end

class Server
  attr_reader :delay_before_start
  attr_reader :port

  def initialize(port, delay_before_start = nil)
    delay_before_start ||= 0.2
    @delay_before_start = delay_before_start
    @port = port
  end

  def run(&blk)
    sleep delay_before_start

    server_connection = Connection::Server.build "127.0.0.1", port
    blk.(server_connection) if block_given?

    logger.trace "Accepting connection"
    server_connection.accept do |client|
      logger.trace "Receiving request"
      request = client.gets
      logger.trace "Sending response"
      client.puts "PONG"
    end
  end
end

describe "Immediate connections" do
  next
  response = nil

  Connection::Policy::Immediate.retry_interval = 0.05

  client_thread = Thread.new do
    Thread.current.abort_on_exception = true
    client = Client.new 9990
    response = client.run
  end

  server = Server.new 9990
  server.run
  client_thread.join

  assert response, :equals => "PONG\n"
end

describe "Cooperative connections" do
  reactor = Connection::Reactor.build

  server = Server.new 9991
  client = Client.new 9991
  reactor.register client
  reactor.register server

  reactor.run
end
