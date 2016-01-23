require_relative './client_spec_init'

describe 'Client Connection' do
  describe 'Reading' do
    specify 'A Single Line' do
      io = StringIO.new "some-line\nother-line\n"
      establish_connection = ->(_) { io }
      client = Connection::Client.new establish_connection

      data = client.readline

      assert data == "some-line\n"
    end

    describe 'Data' do
      specify 'Without Arguments' do
        io = StringIO.new 'some-message'
        establish_connection = ->(_) { io }
        client = Connection::Client.new establish_connection

        data = client.read

        assert data == 'some-message'
      end

      specify 'Fixed Length' do
        io = StringIO.new 'some-message'
        establish_connection = ->(_) { io }
        client = Connection::Client.new establish_connection

        data = client.read 4

        assert data == 'some'
      end

      specify 'Output Buffer' do
        io = StringIO.new 'some-message'
        establish_connection = ->(_) { io }
        client = Connection::Client.new establish_connection
        outbuf = ''

        client.read nil, outbuf

        assert outbuf == 'some-message'
      end

      specify 'Output Buffer and Fixed Length' do
        io = StringIO.new 'some-message'
        establish_connection = ->(_) { io }
        client = Connection::Client.new establish_connection
        outbuf = ''

        client.read 4, outbuf

        assert outbuf == 'some'
      end
    end

    describe 'Errors' do
      specify 'Remote Closed Connection' do
        Connection::Controls::IO.tcp_pair do |io, remote|
          remote.close

          establish_connection = ->(_) { io }
          client = Connection::Client.build establish_connection
          client.telemetry.start_recording

          begin
            client.read
          rescue IOError => error
          end

          assert client.telemetry.closed?
          assert error
        end
      end

      specify 'Remote Reset Connection' do
        Connection::Controls::IO.tcp_pair do |io, remote|
          Connection::Controls::IO.reset_connection remote

          establish_connection = ->(_) { io }
          client = Connection::Client.build establish_connection
          client.telemetry.start_recording

          begin
            client.read
          rescue Errno::ECONNRESET => error
          end

          assert client.telemetry.connection_reset?
          assert error
        end
      end
    end
  end

  describe 'Writing' do
    specify 'Data' do
      io = StringIO.new
      establish_connection = ->(_) { io }
      client = Connection::Client.new establish_connection

      bytes_written = client.write 'some-message'

      assert io.string, :equals => 'some-message'
      assert bytes_written, :equals => 12
    end

    specify 'Remote Closed Connection' do
      Connection::Controls::IO.tcp_pair 9988 do |io, remote|
        remote.close

        establish_connection = ->(_) { io }
        client = Connection::Client.build establish_connection
        client.telemetry.start_recording

        begin
          loop do
            client.write 'some-message'
          end
        rescue Errno::EPIPE => error
        end

        assert client.telemetry.broken_pipe?
        assert error
      end
    end

    specify 'Remote Reset Connection' do
      Connection::Controls::IO.tcp_pair do |io, remote|
        Connection::Controls::IO.reset_connection remote

        establish_connection = ->(_) { io }
        client = Connection::Client.build establish_connection
        client.telemetry.start_recording

        begin
          client.write 'some-message'
        rescue Errno::EPIPE => error
        end

        assert client.telemetry.broken_pipe?
        assert error
      end
    end
  end

  describe 'Closing' do
    specify 'Graceful' do
      io = StringIO.new
      establish_connection = ->(_) { io }
      client = Connection::Client.build establish_connection
      client.telemetry.start_recording

      client.close

      assert client.closed?
      assert client.fileno.nil?
      assert client.telemetry.closed?
    end

    specify 'Already Closed' do
      io = StringIO.new
      establish_connection = ->(_) { io }
      client = Connection::Client.build establish_connection
      client.telemetry.start_recording

      io.close

      begin
        client.read
      rescue IOError => error
      end

      assert error
      assert client.closed?
      assert client.telemetry.closed?
    end
  end
end
