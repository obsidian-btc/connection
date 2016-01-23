module Connection
  class Client
    class EstablishConnection
      dependency :logger, ::Telemetry::Logger

      def self.build(host, port, ssl_context: nil)
        if ssl_context
          SSL.build host, port, ssl_context
        else
          NonSSL.build host, port
        end
      end

      class SSL < EstablishConnection
        attr_reader :host
        attr_reader :port
        attr_reader :ssl_context

        def initialize(host, port, ssl_context)
          @host = host
          @port = port
          @ssl_context = ssl_context
        end

        def self.build(host, port, ssl_context, scheduler: nil)
          instance = new host, port, ssl_context
          ::Telemetry::Logger.configure instance
          instance
        end

        def call(scheduler)
          logger.trace "Establishing encrypted connection (Host: #{host.inspect}, Port: #{port})"

          raw_socket = TCPSocket.new host, port
          ssl_socket = OpenSSL::SSL::SSLSocket.new raw_socket, ssl_context
          handshake ssl_socket, scheduler

          logger.debug "Established encrypted connection (Host: #{host.inspect}, Port: #{port})"

          ssl_socket
        end

        def handshake(ssl_socket, scheduler)
          raw_io = ssl_socket.to_io

          logger.trace "Connecting (Fileno: #{raw_io.fileno})"

          Operation.read raw_io, scheduler do
            ssl_socket.connect_nonblock
          end

          logger.debug "Connected (Fileno: #{raw_io.fileno})"
        end
      end

      class NonSSL < EstablishConnection
        attr_reader :host
        attr_reader :port

        def initialize(host, port)
          @host = host
          @port = port
        end

        def self.build(host, port)
          instance = new host, port
          ::Telemetry::Logger.configure instance
          instance
        end

        def call(_)
          logger.trace "Establishing connection (Host: #{host.inspect}, Port: #{port})"

          socket = TCPSocket.new host, port

          logger.debug "Established connection (Host: #{host.inspect}, Port: #{port})"

          socket
        end
      end
    end
  end
end
