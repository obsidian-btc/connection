module Connection
  class Server
    class Client
      include Proxy
      include Proxy::IOMethods

      attr_reader :socket

      dependency :logger

      def initialize(socket)
        @socket = socket
      end

      def self.build(socket)
        instance = new socket
        Telemetry::Logger.configure instance
        instance
      end
    end
  end
end
