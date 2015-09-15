require "ftest/script"
require "connection"
require "connection/controls"

Thread.abort_on_exception = true

server_thread = Thread.new do
  server = Connection::Controls::ExampleServer.build
  server.run
end

client_thread = Thread.new do
  Thread.pass # Let server finish setting up

  client = Connection::Controls::ExampleClient.build
  assert client.counter > 0
  client.run

  assert client.counter, :equals => 0
end

client_thread.join
logger.debug "Client finished"
server_thread.join
logger.debug "Server finished"
