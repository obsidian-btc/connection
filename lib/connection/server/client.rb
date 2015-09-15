module Connection
  class Server
    class Client
      include Connection
      include Connection::IOMethods

      attr_reader :socket

      def initialize(socket)
        @socket = socket
      end
    end
  end
end
