module Connection
  module Controls
    module IO
      extend self

      def blocked_read_pair(&block)
        tcp_pair do |read_io, write_io|
          block.(read_io, write_io)
        end
      end

      def blocked_write_pair(&block)
        blocked_read_pair do |read_io, write_io|
          bytes_in_write_buffer = block_write_io write_io

          block.(read_io, write_io, bytes_in_write_buffer)
        end
      end

      def block_write_io(io)
        count ||= 0
        data ||= "\x00" * 1024
        retries ||= 0

        loop do
          io.write_nonblock data
          count += 1
        end

        fail

      rescue ::IO::EAGAINWaitWritable
        retries += 1

        if retries == 2
          return count * 1024
        else
          retry
        end
      end

      def reset_connection(socket)
        linger = [1,0].pack 'ii'
        socket.setsockopt Socket::SOL_SOCKET, Socket::SO_LINGER, linger
        socket.close
      end

      def tcp_pair(port=nil, &block)
        port ||= 2000

        server = TCPServer.new '127.0.0.1', port
        client = TCPSocket.new '127.0.0.1', port
        server_client = server.accept_nonblock

        client.sync = true
        server_client.sync = true

        block.(client, server_client)

      ensure

        server_client.close unless server_client.closed?
        client.close unless client.closed?
        server.close
      end
    end
  end
end
