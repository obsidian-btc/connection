require_relative "./reactor_tests_init"

reactor = Connection::Reactor.build

describe "Detecting processes that don't meet contract" do
  DoesNotMeetContract = Module.new

  reactor = Connection::Reactor.build

  specify "Raises error" do
    errors = 0
    begin
      reactor.register DoesNotMeetContract
    rescue Connection::Reactor::InvalidProcess
      errors += 1
    end
    assert errors == 1
  end
end
