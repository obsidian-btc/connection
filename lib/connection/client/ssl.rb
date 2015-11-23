module Connection
  class Client
    class SSL < Client
      def handshake
        logger.trace "Connecting (Fileno: #{fileno})"

        Operation.read to_io, scheduler do
          io.connect_nonblock
        end

        logger.debug "Connected (Fileno: #{fileno})"
      end
    end
  end
end
