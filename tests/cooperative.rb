require "ftest/script"
require "connection"
require "connection/controls"

reactor = Connection::Reactor.build
server = Connection::Controls::ExampleServer.cooperative reactor
client = Connection::Controls::ExampleClient.cooperative reactor

logger.trace "Starting reactor"
assert client.counter > 0
reactor.run
logger.debug "Reactor finished running"

assert client.counter, :equals => 0
