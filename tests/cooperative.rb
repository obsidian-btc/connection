require "ftest/script"
require "connection"
require "connection/controls"

reactor = Connection::Reactor.build
server = Connection::Controls::ExampleServer.build
client = Connection::Controls::ExampleClient.build
reactor.register server
reactor.register client

logger.trace "Starting reactor"
assert client.counter > 0
reactor.run
logger.debug "Reactor finished running"

assert client.counter, :equals => 0
