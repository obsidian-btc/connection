require_relative "./tests_init"

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
