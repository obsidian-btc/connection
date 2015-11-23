module Connection
  module Controls
    module IO
      extend self

      def blocked_read_pair
        read_io, write_io = UNIXSocket.pair
        read_io.sync = true
        write_io.sync = true
        return read_io, write_io
      end

      def blocked_write_pair
        read_io, write_io = blocked_read_pair
        count = block_write_io write_io
        return read_io, write_io, count
      end

      def block_write_io(io)
        count = 0
        data = "\x00" * 1024
        loop do
          io.write_nonblock 1024
          count += 1
        end
      rescue ::IO::EAGAINWaitWritable
        return count * 1024
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
