require_relative "./spec_init"

describe "Immediate policy" do
  Thread.abort_on_exception = true

  specify "Running" do
    server_thread = Thread.new do
      server = Connection::Controls::ExampleServer.build 9001
      server.start
    end

    client_thread = Thread.new do
      Thread.pass # Let server finish setting up

      client = Connection::Controls::ExampleClient.build 9001
      client.start
    end

    client_thread.join
    server_thread.join
  end
end
