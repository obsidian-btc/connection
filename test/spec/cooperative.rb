require_relative "./spec_init"

describe "Cooperative" do
  reactor = Connection::Reactor.build
  server = Connection::Controls::ExampleServer.build 9000
  client = Connection::Controls::ExampleClient.build 9000
  reactor.register server, "some-server"
  reactor.register client, "some-client"

  specify "Running reactor" do
    assert client.counter > 0
    reactor.run
    assert client.counter == 0
  end
end
