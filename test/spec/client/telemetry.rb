require_relative './client_spec_init'

describe 'Client Telemetry' do
  now = Time.parse(Controls::Time.reference)

  specify 'Reads' do
    telemetry = Connection::Client::Telemetry.new
    telemetry.clock.now = now

    telemetry.read 'some-message'

    __logger.data telemetry.pretty_print
    assert_equal <<-TELEMETRY.chomp, telemetry.pretty_print
[
  {
    "operation": "read",
    "time": #{now.iso8601(3).inspect},
    "data": "some-message"
  }
]
    TELEMETRY
  end

  specify 'Writes' do
    telemetry = Connection::Client::Telemetry.new
    telemetry.clock.now = now

    telemetry.wrote 'some-message', 4

    __logger.data telemetry.pretty_print
    assert_equal <<-TELEMETRY.chomp, telemetry.pretty_print
[
  {
    "operation": "wrote",
    "time": #{now.iso8601(3).inspect},
    "data": "some"
  }
]
    TELEMETRY
  end

  specify 'Bytes Received' do
    telemetry = Connection::Client::Telemetry.new
    telemetry.clock.now = now

    telemetry.read 'some-message'
    telemetry.read 'other-message'

    assert telemetry.bytes_received == 25
  end

  specify 'Bytes Sent' do
    telemetry = Connection::Client::Telemetry.new
    telemetry.clock.now = now

    telemetry.wrote 'some-message', 1
    telemetry.wrote 'other-message', 1

    assert telemetry.bytes_sent == 2
  end

  specify 'Connection Reset' do
    telemetry = Connection::Client::Telemetry.new
    telemetry.connection_reset
    assert telemetry.connection_reset?
  end

  specify 'Remote Connection Closed' do
    telemetry = Connection::Client::Telemetry.new
    telemetry.broken_pipe
    assert telemetry.broken_pipe?
  end

  specify 'Connection Closed Gracefully' do
    telemetry = Connection::Client::Telemetry.new
    telemetry.closed
    assert telemetry.closed?
  end
end
