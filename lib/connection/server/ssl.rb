module Connection
  class Server
    class SSL < Server
      def accept
        io.start_immediately = false

        logger.trace "Accepting Connection (Server Fileno: #{fileno})"

        ssl_socket = Operation.read to_io, scheduler do |_, attempt|
          raise IO::EAGAINWaitReadable if attempt.zero?
          io.accept
        end

        logger.debug "Accepted Connection (Client Fileno: #{ssl_socket.to_io.fileno}, Server Fileno: #{fileno})"

        client = build_client ssl_socket, Client
        client.handshake
        client
      end

      class Client < Connection::Client
        def handshake
          logger.trace "Accepting Handshake (Client Fileno: #{fileno})"

          Operation.read to_io, scheduler do
            io.accept_nonblock
          end

          logger.debug "Accepted Handshake (Client Fileno: #{fileno})"
        end
      end
    end
  end
end
