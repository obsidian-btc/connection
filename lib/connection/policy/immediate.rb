module Connection
  module Policy
    module Immediate
      extend self

      attr_writer :retry_interval

      def retry_interval
        @retry_interval or Connection::RETRY_INTERVAL
      end

      def connect(host, port)
        TCPSocket.new host, port
      rescue Errno::ECONNREFUSED
        seconds = Rational(retry_interval, 1000)
        sleep seconds
        retry
      end

      def accept(server_socket)
        client_socket = server_socket.accept
        client_socket
      end

      def gets(socket, separator_or_limit, limit)
        if limit
          socket.gets separator_or_limit, limit
        elsif separator_or_limit
          socket.gets separator_or_limit
        else
          socket.gets
        end
      end

      def puts(socket, *lines)
        socket.puts *lines
      end

      def read(socket, bytes = nil)
        socket.read bytes
      end

      def write(socket, data)
        socket.write data
      end
    end
  end
end
