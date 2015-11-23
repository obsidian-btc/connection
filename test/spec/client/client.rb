require_relative './client_spec_init'

describe 'Client Connection' do
  describe 'Reading' do
    specify 'A Single Line' do
      io = StringIO.new "some-line\nother-line\n"
      client = Connection::Client.new io

      data = io.readline

      assert data == "some-line\n"
    end

    describe 'Data' do
      specify 'Without Arguments' do
        io = StringIO.new 'some-message'
        client = Connection::Client.new io

        data = io.read

        assert data == 'some-message'
      end

      specify 'Fixed Length' do
        io = StringIO.new 'some-message'
        client = Connection::Client.new io

        data = io.read 4

        assert data == 'some'
      end

      specify 'Output Buffer' do
        io = StringIO.new 'some-message'
        client = Connection::Client.new io
        outbuf = ''

        io.read nil, outbuf

        assert outbuf == 'some-message'
      end

      specify 'Output Buffer and Fixed Length' do
        io = StringIO.new 'some-message'
        client = Connection::Client.new io
        outbuf = ''

        io.read 4, outbuf

        assert outbuf == 'some'
      end
    end

    describe 'Errors' do
      specify 'Remote Closed Connection' do
        Connection::Controls.tcp_pair do |io, remote|
          remote.close

          client = Connection::Client.build io

          begin
            client.read
          rescue IOError => error
          end

          assert client.telemetry.closed?
          assert error
        end
      end

      specify 'Remote Reset Connection' do
        Connection::Controls.reset_connection do |io, remote|
          remote.close

          client = Connection::Client.build io

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
      client = Connection::Client.new io

      bytes_written = client.write 'some-message'

      assert io.string, :equals => 'some-message'
      assert bytes_written, :equals => 12
    end

    specify 'Remote Closed Connection' do
      Connection::Controls.tcp_pair 9988 do |io, remote|
        remote.close

        client = Connection::Client.build io

        begin
          loop do
            client.write 'some-message'
          end
        rescue Errno::EPIPE => error
        end

        assert client.telemetry.broken_pipe?
      end
    end

    specify 'Remote Reset Connection' do
      Connection::Controls.reset_connection do |io, remote|
        remote.close

        client = Connection::Client.build io

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
      client = Connection::Client.build io

      client.close

      assert client.closed?
      assert client.telemetry.closed?
    end

    specify 'Already Closed' do
      io = StringIO.new
      client = Connection::Client.build io

      io.close

      begin
        client.close
      rescue IOError => error
      end

      assert error
      assert client.closed?
      assert client.telemetry.closed?
    end
  end
end
