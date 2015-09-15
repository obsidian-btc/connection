module Connection
  module Policy
    class Cooperative
      def self.build(reactor)
        instance = new reactor
        Telemetry::Logger.configure instance
        instance
      end

      attr_reader :reactor
      attr_accessor :fiber

      dependency :logger, Telemetry::Logger

      def initialize(reactor)
        @reactor = reactor
      end

      def accept(server_socket)
        reactor.wait_readable server_socket do
          client_socket = server_socket.accept_nonblock
          resume_fiber client_socket
        end
        yield_fiber
      end

      def gets(socket, separator_or_limit, limit)
        reactor.wait_readable socket do
          return_value =
            if limit
              socket.gets separator_or_limit, limit
            elsif separator_or_limit
              socket.gets separator_or_limit
            else
              socket.gets
            end
          resume_fiber return_value
        end
        yield_fiber
      end

      def puts(socket, *lines)
        reactor.wait_writable socket do
          return_value = socket.puts *lines
          resume_fiber return_value
        end
        yield_fiber
      end

      def read(socket, bytes = nil)
        reactor.wait_readable socket do
          return_value = socket.read bytes
          resume_fiber return_value
        end
        yield_fiber
      end

      def write(socket, data)
        reactor.wait_writable socket do
          return_value = socket.write data
          resume_fiber return_value
        end
        yield_fiber
      end

      def resume_fiber(return_value)
        logger.trace "Reactor indicated we're ready to return control to client"
        fiber.resume return_value
      end

      def yield_fiber
        logger.trace "Returning control to reactor"
        self.fiber = Fiber.current
        Fiber.yield
      end
    end
  end
end
