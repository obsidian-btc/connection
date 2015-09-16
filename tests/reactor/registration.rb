require_relative "./reactor_tests_init"

reactor = Connection::Reactor.build

describe "Detecting processes that don't meet contract" do
  DoesNotMeetContract = Module.new

  reactor = Connection::Reactor.build

  assert :raises => Connection::Reactor::InvalidProcess do
    reactor.register DoesNotMeetContract
  end
end
